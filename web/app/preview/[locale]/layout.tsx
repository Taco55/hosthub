import { notFound } from "next/navigation";

import { Footer } from "@/components/footer";
import { Header } from "@/components/header";
import { PreviewBanner } from "@/components/preview-banner";
import { isLocale } from "@/lib/i18n";

type LayoutProps = {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
};

export default async function PreviewLocaleLayout({ children, params }: LayoutProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col">
      <PreviewBanner locale={locale} />
      <Header locale={locale} />
      <main className="flex-1">{children}</main>
      <Footer locale={locale} pathPrefix="/preview" />
    </div>
  );
}
