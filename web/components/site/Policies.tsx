import { FileText } from "lucide-react";

import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { IconBadge } from "@/components/ui/IconBadge";
import type { PolicyBlock } from "@/lib/content";
import { cmsField } from "@/lib/cms-field";
import { rowFieldPath, textRows } from "@/lib/cms-rows";
import { cn } from "@/lib/utils";

type PoliciesProps = {
  title: string;
  blocks: PolicyBlock[];
  className?: string;
};

export function Policies({ title, blocks, className }: PoliciesProps) {
  return (
    <Card className={cn("mx-auto w-full max-w-4xl bg-white text-left", className)}>
      <CardHeader className="flex-row items-center gap-3 pb-4">
        <IconBadge size="sm" icon={<FileText />} />
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <Accordion type="multiple" className="space-y-2">
          {blocks.map((block, index) => {
            const blockId = block.id ?? index;
            return (
              <AccordionItem
                key={blockId}
                value={`${block.title}-${index}`}
                className="border-border/40 last:border-b-0"
              >
                <AccordionTrigger
                  className="justify-between text-left text-base font-medium text-[color:rgb(var(--heading-warm-light))] md:text-lg"
                  {...cmsField(
                    "page/practical",
                    "agreementsAndPayment",
                    "blocks",
                    blockId,
                    "title",
                  )}
                >
                  {block.title}
                </AccordionTrigger>
                <AccordionContent className="text-left text-base leading-7 text-slate-600">
                  <ul className="list-disc list-inside space-y-2">
                    {textRows(block.items).map((row, itemIndex) => (
                      <li
                        key={row.id ?? itemIndex}
                        {...cmsField(
                          "page/practical",
                          "agreementsAndPayment",
                          "blocks",
                          blockId,
                          ...rowFieldPath("items", row, itemIndex),
                        )}
                      >
                        {row.text}
                      </li>
                    ))}
                  </ul>
                </AccordionContent>
              </AccordionItem>
            );
          })}
        </Accordion>
      </CardContent>
    </Card>
  );
}
