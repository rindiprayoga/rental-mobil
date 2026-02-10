import { Link } from "react-router-dom";
import { Target, Heart, Users, Award, CheckCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import Layout from "@/components/Layout";

const values = [
  {
    icon: Target,
    title: "Our Mission",
    description:
      "To provide reliable, affordable, and convenient car rental services that make every journey memorable for families and individuals alike.",
  },
  {
    icon: Heart,
    title: "Customer First",
    description:
      "We prioritize your satisfaction above all else. Every decision we make is centered around providing you with the best possible experience.",
  },
  {
    icon: Users,
    title: "Family Focused",
    description:
      "We understand the needs of families on the go. Our fleet is specially curated with spacious MPVs and comfortable SUVs for family adventures.",
  },
  {
    icon: Award,
    title: "Quality Service",
    description:
      "From well-maintained vehicles to responsive customer support, we maintain the highest standards in everything we do.",
  },
];

const reasons = [
  "Over 8 years of trusted service",
  "Fleet of 100+ well-maintained vehicles",
  "Transparent pricing with no hidden fees",
  "Flexible pickup and drop-off options",
  "24/7 roadside assistance",
  "Easy online booking process",
  "Comprehensive insurance options",
  "Dedicated customer support team",
];

const About = () => {
  return (
    <Layout>
      {/* Hero */}
      <section className="bg-gradient-to-br from-secondary to-background py-16 md:py-24">
        <div className="container">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-4xl font-bold text-foreground md:text-5xl">
              About <span className="text-primary">RentDrive</span>
            </h1>
            <p className="mt-6 text-lg text-muted-foreground">
              Since 2015, we've been helping families and individuals find the perfect 
              vehicle for their journeys. Our commitment to quality, affordability, 
              and exceptional service has made us a trusted name in car rentals.
            </p>
          </div>
        </div>
      </section>

      {/* Story */}
      <section className="py-16 md:py-24 bg-background">
        <div className="container">
          <div className="grid gap-12 lg:grid-cols-2 lg:items-center">
            <div>
              <img
                src="https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=800&auto=format&fit=crop&q=80"
                alt="Our office"
                className="rounded-3xl shadow-xl w-full aspect-[4/3] object-cover"
              />
            </div>
            <div className="space-y-6">
              <h2 className="text-3xl font-bold text-foreground md:text-4xl">
                Our Story
              </h2>
              <p className="text-muted-foreground">
                RentDrive started with a simple idea: car rental should be easy, 
                affordable, and stress-free. What began as a small family business 
                with just 5 cars has grown into a trusted fleet of over 100 vehicles.
              </p>
              <p className="text-muted-foreground">
                We noticed that many families struggled to find spacious, reliable 
                vehicles for their trips. That's why we focused on building a fleet 
                of MPVs and SUVs – perfect for road trips, airport pickups, and 
                everyday family needs.
              </p>
              <p className="text-muted-foreground">
                Today, we're proud to serve thousands of happy customers each year, 
                maintaining our core values of quality, transparency, and exceptional 
                customer service.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Values */}
      <section className="py-16 md:py-24 bg-secondary">
        <div className="container">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-foreground md:text-4xl">
              Our Values
            </h2>
            <p className="mt-3 text-muted-foreground">
              The principles that guide everything we do
            </p>
          </div>
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            {values.map((value, index) => (
              <Card key={index} className="border-0 shadow-md">
                <CardContent className="pt-8 pb-6 text-center">
                  <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
                    <value.icon className="h-8 w-8 text-primary" />
                  </div>
                  <h3 className="text-lg font-semibold text-foreground">
                    {value.title}
                  </h3>
                  <p className="mt-2 text-sm text-muted-foreground">
                    {value.description}
                  </p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Why Choose Us */}
      <section className="py-16 md:py-24 bg-background">
        <div className="container">
          <div className="grid gap-12 lg:grid-cols-2 lg:items-center">
            <div className="space-y-6">
              <h2 className="text-3xl font-bold text-foreground md:text-4xl">
                Why Choose RentDrive?
              </h2>
              <p className="text-muted-foreground">
                We go above and beyond to ensure your rental experience is nothing 
                short of excellent. Here's what sets us apart:
              </p>
              <div className="grid gap-3 sm:grid-cols-2">
                {reasons.map((reason, index) => (
                  <div key={index} className="flex items-center gap-2">
                    <CheckCircle className="h-5 w-5 text-primary flex-shrink-0" />
                    <span className="text-sm text-foreground">{reason}</span>
                  </div>
                ))}
              </div>
              <Button asChild size="lg" className="rounded-full mt-4">
                <Link to="/catalog">Explore Our Cars</Link>
              </Button>
            </div>
            <div>
              <img
                src="https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=800&auto=format&fit=crop&q=80"
                alt="Happy customer"
                className="rounded-3xl shadow-xl w-full aspect-[4/3] object-cover"
              />
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-16 md:py-24 bg-primary">
        <div className="container text-center">
          <h2 className="text-3xl font-bold text-primary-foreground md:text-4xl">
            Ready to Experience the Difference?
          </h2>
          <p className="mt-4 text-primary-foreground/80 max-w-2xl mx-auto">
            Join thousands of satisfied customers and book your next rental with us
          </p>
          <Button asChild size="lg" variant="secondary" className="mt-8 rounded-full">
            <Link to="/contact">Book Now</Link>
          </Button>
        </div>
      </section>
    </Layout>
  );
};

export default About;
