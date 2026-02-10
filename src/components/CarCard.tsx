import { Users, Gauge } from "lucide-react";
import { Card, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Car } from "@/data/cars";
import { Link } from "react-router-dom";

interface CarCardProps {
  car: Car;
}

const CarCard = ({ car }: CarCardProps) => {
  const typeColors = {
    MPV: "bg-primary/10 text-primary border-primary/20",
    SUV: "bg-emerald-500/10 text-emerald-600 border-emerald-500/20",
    Sedan: "bg-blue-500/10 text-blue-600 border-blue-500/20",
  };

  return (
    <Card className="overflow-hidden transition-all duration-300 hover:shadow-lg hover:-translate-y-1 group">
      <div className="relative aspect-[16/10] overflow-hidden">
        <img
          src={car.image}
          alt={car.name}
          className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
        />
        <Badge
          variant="outline"
          className={`absolute top-3 left-3 ${typeColors[car.type]}`}
        >
          {car.type}
        </Badge>
      </div>
      <CardContent className="p-4">
        <h3 className="text-lg font-semibold text-foreground">{car.name}</h3>
        <div className="mt-2 flex items-center gap-4 text-sm text-muted-foreground">
          <div className="flex items-center gap-1">
            <Users className="h-4 w-4" />
            <span>{car.capacity} seats</span>
          </div>
          <div className="flex items-center gap-1">
            <Gauge className="h-4 w-4" />
            <span>{car.transmission}</span>
          </div>
        </div>
        <div className="mt-3">
          <span className="text-2xl font-bold text-primary">${car.pricePerDay}</span>
          <span className="text-sm text-muted-foreground"> / day</span>
        </div>
      </CardContent>
      <CardFooter className="p-4 pt-0">
        <Button asChild className="w-full rounded-full">
          <Link to="/contact">Book Now</Link>
        </Button>
      </CardFooter>
    </Card>
  );
};

export default CarCard;
