import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/users/application/users_cubit.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/create_user_dialog.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleAuthChanged(context.read<AuthBloc>().state);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleAuthChanged(AuthState state) {
    final usersCubit = context.read<UsersCubit>();
    if (state.status == AuthStatus.authenticated) {
      unawaited(usersCubit.ensureLoaded());
      if (_searchController.text != usersCubit.state.searchQuery) {
        _searchController.text = usersCubit.state.searchQuery;
      }
    } else {
      _searchController.clear();
      usersCubit.reset();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<UsersCubit>().loadUsers(query: value);
    });
  }

  Future<void> _refreshUsers() {
    final cubit = context.read<UsersCubit>();
    return cubit.loadUsers(query: cubit.state.searchQuery);
  }

  Future<void> _handleCreateUser() async {
    final created = await showCreateUserDialog(context);
    if (!mounted || created != true) return;

    showStyledToast(
      context,
      description: context.s.userCreated,
      type: ToastificationType.success,
      dismissAllBeforeShowing: true,
    );

    await _refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status,
      listener: (context, state) => _handleAuthChanged(state),
      builder: (context, authState) {
        final theme = Theme.of(context);
        final l10n = context.s;
        if (authState.status != AuthStatus.authenticated) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<UsersCubit, UsersState>(
          builder: (context, usersState) {
            return _buildUsersContent(context, theme, l10n, usersState);
          },
        );
      },
    );
  }

  Widget _buildUsersContent(
    BuildContext context,
    ThemeData theme,
    S l10n,
    UsersState usersState,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConsolePageScaffold(
          title: context.s.usersTitle,
          description: context.s.usersSubtitle,
          wrapLeftPane: false,
          wrapRightPane: true,
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 64, 0),
          leftChild: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSearchField(theme, l10n)),
                    const SizedBox(width: 12),
                    StyledButton(
                      title: context.s.createUserButton,
                      onPressed: _handleCreateUser,
                      minHeight: 40,
                      showLeftIcon: true,
                      leftIconData: Icons.person_add_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildUserListCard(context, theme, l10n, usersState),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserListCard(
    BuildContext context,
    ThemeData theme,
    S l10n,
    UsersState usersState,
  ) {
    final listError = usersState.errorMessage;
    final users = usersState.users;

    return Column(
      children: [
        if (usersState.isLoadingList) const LinearProgressIndicator(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshUsers,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
              children: [
                if (listError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      listError,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                StyledDataTable(
                  variant: StyledTableVariant.plain,

                  columns: [
                    StyledDataColumn(columnHeaderLabel: context.s.emailLabel, flex: 4),
                    StyledDataColumn(columnHeaderLabel: context.s.usernameLabel, flex: 3),
                    StyledDataColumn(
                      columnHeaderLabel: context.s.subscriptionLabel,
                      flex: 2,
                    ),
                    StyledDataColumn(columnHeaderLabel: context.s.roleLabel, flex: 2),
                  ],
                  itemCount: users.length,
                  rowBuilder: (tableContext, index) {
                    final profile = users[index];
                    return [
                      Text(
                        profile.email,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        profile.username?.isNotEmpty == true
                            ? profile.username!
                            : context.s.noUsername,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            profile.isAdmin
                                ? Icons.shield_moon_outlined
                                : Icons.person_outline,
                            size: 18,
                            color: profile.isAdmin
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile.isAdmin
                                ? context.s.roleAdmin
                                : context.s.roleUser,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ];
                  },
                  onRowTap: (tableContext, index) =>
                      context.go('/users/${users[index].id}'),
                  emptyLabel: context.s.noUsersFound,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme, S l10n) {
    final colors = theme.colorScheme;
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: context.s.searchEmailHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: context.s.clearSearchTooltip,
                onPressed: () {
                  _searchController.clear();
                  context.read<UsersCubit>().loadUsers(query: '');
                },
                icon: const Icon(Icons.clear),
              ),
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onChanged: _onSearchChanged,
    );
  }
}
