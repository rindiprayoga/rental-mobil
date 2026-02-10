import { useState, useMemo } from "react";
import { Filter } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { Slider } from "@/components/ui/slider";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import Layout from "@/components/Layout";
import CarCard from "@/components/CarCard";
import { cars, Car } from "@/data/cars";

type CarType = "MPV" | "SUV" | "Sedan";

const Catalog = () => {
  const [selectedTypes, setSelectedTypes] = useState<CarType[]>([]);
  const [priceRange, setPriceRange] = useState([0, 200]);
  const [selectedCapacity, setSelectedCapacity] = useState<number[]>([]);

  const capacities = [...new Set(cars.map((car) => car.capacity))].sort((a, b) => a - b);

  const toggleType = (type: CarType) => {
    setSelectedTypes((prev) =>
      prev.includes(type) ? prev.filter((t) => t !== type) : [...prev, type]
    );
  };

  const toggleCapacity = (capacity: number) => {
    setSelectedCapacity((prev) =>
      prev.includes(capacity)
        ? prev.filter((c) => c !== capacity)
        : [...prev, capacity]
    );
  };

  const filteredCars = useMemo(() => {
    let result = [...cars];

    // Filter by type
    if (selectedTypes.length > 0) {
      result = result.filter((car) => selectedTypes.includes(car.type));
    }

    // Filter by price
    result = result.filter(
      (car) => car.pricePerDay >= priceRange[0] && car.pricePerDay <= priceRange[1]
    );

    // Filter by capacity
    if (selectedCapacity.length > 0) {
      result = result.filter((car) => selectedCapacity.includes(car.capacity));
    }

    // Sort: MPVs and SUVs first, then Sedans
    result.sort((a, b) => {
      const typeOrder = { MPV: 0, SUV: 1, Sedan: 2 };
      return typeOrder[a.type] - typeOrder[b.type];
    });

    return result;
  }, [selectedTypes, priceRange, selectedCapacity]);

  const resetFilters = () => {
    setSelectedTypes([]);
    setPriceRange([0, 200]);
    setSelectedCapacity([]);
  };

  const FilterContent = () => (
    <div className="space-y-6">
      {/* Car Type */}
      <div className="space-y-3">
        <Label className="text-base font-semibold">Car Type</Label>
        <div className="space-y-2">
          {(["MPV", "SUV", "Sedan"] as CarType[]).map((type) => (
            <div key={type} className="flex items-center space-x-2">
              <Checkbox
                id={type}
                checked={selectedTypes.includes(type)}
                onCheckedChange={() => toggleType(type)}
              />
              <label
                htmlFor={type}
                className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              >
                {type}
              </label>
            </div>
          ))}
        </div>
      </div>

      {/* Price Range */}
      <div className="space-y-3">
        <Label className="text-base font-semibold">
          Price Range: ${priceRange[0]} - ${priceRange[1]}/day
        </Label>
        <Slider
          value={priceRange}
          onValueChange={setPriceRange}
          max={200}
          min={0}
          step={10}
          className="w-full"
        />
      </div>

      {/* Capacity */}
      <div className="space-y-3">
        <Label className="text-base font-semibold">Capacity</Label>
        <div className="space-y-2">
          {capacities.map((capacity) => (
            <div key={capacity} className="flex items-center space-x-2">
              <Checkbox
                id={`capacity-${capacity}`}
                checked={selectedCapacity.includes(capacity)}
                onCheckedChange={() => toggleCapacity(capacity)}
              />
              <label
                htmlFor={`capacity-${capacity}`}
                className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              >
                {capacity} seats
              </label>
            </div>
          ))}
        </div>
      </div>

      <Button variant="outline" onClick={resetFilters} className="w-full rounded-full">
        Reset Filters
      </Button>
    </div>
  );

  return (
    <Layout>
      {/* Hero */}
      <section className="bg-gradient-to-br from-secondary to-background py-12 md:py-16">
        <div className="container">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-4xl font-bold text-foreground md:text-5xl">
              Our <span className="text-primary">Car Catalog</span>
            </h1>
            <p className="mt-4 text-lg text-muted-foreground">
              Explore our selection of family-friendly MPVs, rugged SUVs, and elegant sedans
            </p>
          </div>
        </div>
      </section>

      {/* Catalog */}
      <section className="py-12 md:py-16 bg-background">
        <div className="container">
          <div className="flex flex-col lg:flex-row gap-8">
            {/* Mobile Filter Button */}
            <div className="lg:hidden">
              <Sheet>
                <SheetTrigger asChild>
                  <Button variant="outline" className="w-full rounded-full">
                    <Filter className="h-4 w-4 mr-2" />
                    Filter Cars
                  </Button>
                </SheetTrigger>
                <SheetContent side="left">
                  <SheetHeader>
                    <SheetTitle>Filter Cars</SheetTitle>
                  </SheetHeader>
                  <div className="mt-6">
                    <FilterContent />
                  </div>
                </SheetContent>
              </Sheet>
            </div>

            {/* Desktop Sidebar */}
            <aside className="hidden lg:block w-64 flex-shrink-0">
              <Card className="sticky top-24">
                <CardContent className="p-6">
                  <h3 className="text-lg font-semibold mb-4">Filter Cars</h3>
                  <FilterContent />
                </CardContent>
              </Card>
            </aside>

            {/* Car Grid */}
            <div className="flex-1">
              <div className="flex items-center justify-between mb-6">
                <p className="text-muted-foreground">
                  Showing <span className="font-medium text-foreground">{filteredCars.length}</span> vehicles
                </p>
              </div>

              {filteredCars.length > 0 ? (
                <div className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
                  {filteredCars.map((car) => (
                    <CarCard key={car.id} car={car} />
                  ))}
                </div>
              ) : (
                <Card className="p-12 text-center">
                  <p className="text-muted-foreground">
                    No cars match your filters. Try adjusting your criteria.
                  </p>
                  <Button variant="outline" onClick={resetFilters} className="mt-4 rounded-full">
                    Reset Filters
                  </Button>
                </Card>
              )}
            </div>
          </div>
        </div>
      </section>
    </Layout>
  );
};

export default Catalog;
