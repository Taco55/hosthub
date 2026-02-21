import { Card, CardContent } from "@/components/ui/card";
import { Review } from "@/lib/content";

type ReviewsGridProps = {
  reviews: Review[];
};

export function ReviewsGrid({ reviews }: ReviewsGridProps) {
  return (
    <div className="grid gap-6 md:grid-cols-3">
      {reviews.map((review) => (
        <Card key={`${review.name}-${review.stay}`} className="bg-background/80">
          <CardContent className="space-y-4 pt-6">
            <p className="text-base leading-7 text-slate-600">“{review.quote}”</p>
            <div className="text-xs uppercase tracking-wide text-muted-foreground">
              {review.name} · {review.stay}
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
