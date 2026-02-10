import { Link } from "react-router-dom";
import { ArrowRight, DollarSign, Wrench, ThumbsUp, Headphones, Car, FileText, CreditCard, CheckCircle, Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import Layout from "@/components/Layout";
import CarCard from "@/components/CarCard";
import { cars, testimonials } from "@/data/cars";

const featuredCars = cars.filter((car) => car.featured);

const benefits = [
  {
    icon: DollarSign,
    title: "Affordable Price",
    description: "Competitive rates with no hidden fees",
  },
  {
    icon: Wrench,
    title: "Well-Maintained",
    description: "Regular servicing for safe journeys",
  },
  {
    icon: ThumbsUp,
    title: "Easy Process",
    description: "Simple booking in just a few steps",
  },
  {
    icon: Headphones,
    title: "24/7 Service",
    description: "Support whenever you need us",
  },
];

const steps = [
  {
    icon: Car,
    step: "Step 1",
    title: "Choose a Car",
    description: "Browse our wide selection of vehicles",
  },
  {
    icon: FileText,
    step: "Step 2",
    title: "Fill Form",
    description: "Provide your details and preferences",
  },
  {
    icon: CreditCard,
    step: "Step 3",
    title: "Confirm & Pay",
    description: "Review and complete your booking",
  },
  {
    icon: CheckCircle,
    step: "Step 4",
    title: "Ready to Go",
    description: "Pick up your car and enjoy the ride",
  },
];

const Index = () => {
  return (
    <Layout>
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-br from-secondary to-background">
        <div className="container py-16 md:py-24 lg:py-32">
          <div className="grid gap-8 lg:grid-cols-2 lg:items-center">
            <div className="space-y-6 text-center lg:text-left animate-fade-in">
              <h1 className="text-4xl font-bold tracking-tight text-foreground md:text-5xl lg:text-6xl">
                Easy & Reliable{" "}
                <span className="text-primary">Car Rental</span>
              </h1>
              <p className="text-lg text-muted-foreground md:text-xl max-w-lg mx-auto lg:mx-0">
                Choose from a wide range of vehicles for your needs. 
                Perfect for family trips, business travel, or weekend adventures.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                <Button asChild size="lg" className="rounded-full text-base">
                  <Link to="/catalog">
                    View All Cars
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Link>
                </Button>
                <Button asChild variant="outline" size="lg" className="rounded-full text-base">
                  <Link to="/contact">Book Now</Link>
                </Button>
              </div>
            </div>
            <div className="relative">
              <img
                src="https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800&auto=format&fit=crop&q=80"
                alt="Featured MPV"
                className="rounded-3xl shadow-2xl w-full aspect-[4/3] object-cover"
              />
              <div className="absolute -bottom-4 -left-4 bg-background rounded-2xl p-4 shadow-lg hidden md:block">
                <div className="flex items-center gap-3">
                  <div className="flex -space-x-2">
                    {testimonials.slice(0, 3).map((t) => (
                      <img
                        key={t.id}
                        src={t.avatar}
                        alt={t.name}
                        className="h-8 w-8 rounded-full border-2 border-background object-cover"
                      />
                    ))}
                  </div>
                  <div className="text-sm">
                    <div className="flex text-primary">
                      {[...Array(5)].map((_, i) => (
                        <Star key={i} className="h-4 w-4 fill-current" />
                      ))}
                    </div>
                    <span className="text-muted-foreground">500+ Happy Customers</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Cars */}
      <section className="py-16 md:py-24 bg-background">
        <div className="container">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-foreground md:text-4xl">
              Featured Vehicles
            </h2>
            <p className="mt-3 text-muted-foreground max-w-2xl mx-auto">
              Discover our most popular MPVs and SUVs, perfect for family travels
            </p>
          </div>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {featuredCars.map((car) => (
              <CarCard key={car.id} car={car} />
            ))}
          </div>
          <div className="text-center mt-10">
            <Button asChild variant="outline" size="lg" className="rounded-full">
              <Link to="/catalog">
                View All Cars
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="py-16 md:py-24 bg-secondary">
        <div className="container">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-foreground md:text-4xl">
              Why Choose Us?
            </h2>
            <p className="mt-3 text-muted-foreground">
              We're committed to making your rental experience exceptional
            </p>
          </div>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {benefits.map((benefit, index) => (
              <Card key={index} className="text-center border-0 shadow-md">
                <CardContent className="pt-8 pb-6">
                  <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
                    <benefit.icon className="h-8 w-8 text-primary" />
                  </div>
                  <h3 className="text-lg font-semibold text-foreground">
                    {benefit.title}
                  </h3>
                  <p className="mt-2 text-sm text-muted-foreground">
                    {benefit.description}
                  </p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* How to Order */}
      <section className="py-16 md:py-24 bg-background">
        <div className="container">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-foreground md:text-4xl">
              How to Rent a Car
            </h2>
            <p className="mt-3 text-muted-foreground">
              Simple steps to get you on the road
            </p>
          </div>
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
            {steps.map((step, index) => (
              <div key={index} className="relative text-center">
                <div className="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-primary text-primary-foreground">
                  <step.icon className="h-10 w-10" />
                </div>
                <span className="text-sm font-medium text-primary">
                  {step.step}
                </span>
                <h3 className="mt-1 text-lg font-semibold text-foreground">
                  {step.title}
                </h3>
                <p className="mt-2 text-sm text-muted-foreground">
                  {step.description}
                </p>
                {index < steps.length - 1 && (
                  <div className="hidden lg:block absolute top-10 left-[60%] w-[80%] border-t-2 border-dashed border-primary/30" />
                )}
              </div>
            ))}
          </div>
          <div className="text-center mt-10">
            <Button asChild size="lg" className="rounded-full">
              <Link to="/how-to-order">Learn More</Link>
            </Button>
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-16 md:py-24 bg-secondary">
        <div className="container">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-foreground md:text-4xl">
              What Our Customers Say
            </h2>
            <p className="mt-3 text-muted-foreground">
              Hear from our satisfied customers
            </p>
          </div>
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            {testimonials.map((testimonial) => (
              <Card key={testimonial.id} className="border-0 shadow-md">
                <CardContent className="pt-6">
                  <div className="flex text-primary mb-4">
                    {[...Array(testimonial.rating)].map((_, i) => (
                      <Star key={i} className="h-4 w-4 fill-current" />
                    ))}
                  </div>
                  <p className="text-muted-foreground text-sm mb-4">
                    "{testimonial.review}"
                  </p>
                  <div className="flex items-center gap-3">
                    <img
                      src={testimonial.avatar}
                      alt={testimonial.name}
                      className="h-10 w-10 rounded-full object-cover"
                    />
                    <span className="font-medium text-foreground">
                      {testimonial.name}
                    </span>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 md:py-24 bg-primary">
        <div className="container text-center">
          <h2 className="text-3xl font-bold text-primary-foreground md:text-4xl">
            Ready to Hit the Road?
          </h2>
          <p className="mt-4 text-primary-foreground/80 max-w-2xl mx-auto">
            Book your perfect vehicle today and enjoy a hassle-free rental experience
          </p>
          <Button asChild size="lg" variant="secondary" className="mt-8 rounded-full text-base">
            <Link to="/contact">
              Book Your Car Now
              <ArrowRight className="ml-2 h-5 w-5" />
            </Link>
          </Button>
        </div>
      </section>
    </Layout>
  );
};

export default Index;
