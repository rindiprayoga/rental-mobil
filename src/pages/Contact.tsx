import { useState } from "react";
import { MapPin, Phone, Mail, Clock, Send, MessageCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import Layout from "@/components/Layout";
import { cars } from "@/data/cars";

const contactInfo = [
  {
    icon: MapPin,
    title: "Visit Us",
    details: ["123 Main Street", "Downtown, City 12345"],
  },
  {
    icon: Phone,
    title: "Call Us",
    details: ["+1 (555) 123-4567", "WhatsApp available"],
  },
  {
    icon: Mail,
    title: "Email Us",
    details: ["hello@rentdrive.com", "support@rentdrive.com"],
  },
  {
    icon: Clock,
    title: "Business Hours",
    details: ["Mon - Sat: 8:00 AM - 10:00 PM", "Sunday: 9:00 AM - 6:00 PM"],
  },
];

const Contact = () => {
  const { toast } = useToast();
  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    email: "",
    car: "",
    pickupDate: "",
    returnDate: "",
    message: "",
  });

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleCarSelect = (value: string) => {
    setFormData((prev) => ({ ...prev, car: value }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // In a real app, this would send the data to a backend
    toast({
      title: "Booking Request Sent!",
      description: "We'll contact you shortly to confirm your reservation.",
    });
    setFormData({
      name: "",
      phone: "",
      email: "",
      car: "",
      pickupDate: "",
      returnDate: "",
      message: "",
    });
  };

  return (
    <Layout>
      {/* Hero */}
      <section className="bg-gradient-to-br from-secondary to-background py-16 md:py-24">
        <div className="container">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-4xl font-bold text-foreground md:text-5xl">
              Contact <span className="text-primary">Us</span>
            </h1>
            <p className="mt-6 text-lg text-muted-foreground">
              Ready to book your car? Have questions? We're here to help. 
              Reach out to us through any of the channels below.
            </p>
          </div>
        </div>
      </section>

      {/* Contact Info Cards */}
      <section className="py-12 md:py-16 bg-background">
        <div className="container">
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {contactInfo.map((info, index) => (
              <Card key={index} className="text-center border-0 shadow-md">
                <CardContent className="pt-8 pb-6">
                  <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
                    <info.icon className="h-7 w-7 text-primary" />
                  </div>
                  <h3 className="font-semibold text-foreground">{info.title}</h3>
                  {info.details.map((detail, i) => (
                    <p key={i} className="text-sm text-muted-foreground mt-1">
                      {detail}
                    </p>
                  ))}
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Booking Form & Map */}
      <section className="py-12 md:py-16 bg-secondary">
        <div className="container">
          <div className="grid gap-8 lg:grid-cols-2">
            {/* Booking Form */}
            <Card className="border-0 shadow-lg">
              <CardHeader>
                <CardTitle className="text-2xl flex items-center gap-2">
                  <MessageCircle className="h-6 w-6 text-primary" />
                  Book Your Car
                </CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit} className="space-y-4">
                  <div className="grid gap-4 sm:grid-cols-2">
                    <div className="space-y-2">
                      <Label htmlFor="name">Full Name *</Label>
                      <Input
                        id="name"
                        name="name"
                        placeholder="John Doe"
                        value={formData.name}
                        onChange={handleChange}
                        required
                        className="rounded-lg"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="phone">Phone / WhatsApp *</Label>
                      <Input
                        id="phone"
                        name="phone"
                        placeholder="+1 (555) 123-4567"
                        value={formData.phone}
                        onChange={handleChange}
                        required
                        className="rounded-lg"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="email">Email</Label>
                    <Input
                      id="email"
                      name="email"
                      type="email"
                      placeholder="john@example.com"
                      value={formData.email}
                      onChange={handleChange}
                      className="rounded-lg"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="car">Select Car *</Label>
                    <Select value={formData.car} onValueChange={handleCarSelect} required>
                      <SelectTrigger className="rounded-lg">
                        <SelectValue placeholder="Choose a vehicle" />
                      </SelectTrigger>
                      <SelectContent>
                        {cars.map((car) => (
                          <SelectItem key={car.id} value={car.id}>
                            {car.name} - ${car.pricePerDay}/day
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="grid gap-4 sm:grid-cols-2">
                    <div className="space-y-2">
                      <Label htmlFor="pickupDate">Pickup Date *</Label>
                      <Input
                        id="pickupDate"
                        name="pickupDate"
                        type="date"
                        value={formData.pickupDate}
                        onChange={handleChange}
                        required
                        className="rounded-lg"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="returnDate">Return Date *</Label>
                      <Input
                        id="returnDate"
                        name="returnDate"
                        type="date"
                        value={formData.returnDate}
                        onChange={handleChange}
                        required
                        className="rounded-lg"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="message">Additional Notes</Label>
                    <Textarea
                      id="message"
                      name="message"
                      placeholder="Any special requests or questions?"
                      value={formData.message}
                      onChange={handleChange}
                      rows={4}
                      className="rounded-lg"
                    />
                  </div>

                  <Button type="submit" size="lg" className="w-full rounded-full">
                    <Send className="h-4 w-4 mr-2" />
                    Submit Booking Request
                  </Button>
                </form>
              </CardContent>
            </Card>

            {/* Map Placeholder */}
            <Card className="border-0 shadow-lg overflow-hidden">
              <div className="h-full min-h-[400px] bg-muted flex items-center justify-center">
                <div className="text-center p-8">
                  <MapPin className="h-16 w-16 text-primary mx-auto mb-4" />
                  <h3 className="text-xl font-semibold text-foreground mb-2">
                    Find Us Here
                  </h3>
                  <p className="text-muted-foreground mb-4">
                    123 Main Street, Downtown, City 12345
                  </p>
                  <Button variant="outline" className="rounded-full" asChild>
                    <a
                      href="https://maps.google.com"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      Open in Google Maps
                    </a>
                  </Button>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </section>

      {/* WhatsApp CTA */}
      <section className="py-16 md:py-24 bg-primary">
        <div className="container text-center">
          <h2 className="text-3xl font-bold text-primary-foreground md:text-4xl">
            Prefer WhatsApp?
          </h2>
          <p className="mt-4 text-primary-foreground/80 max-w-2xl mx-auto">
            Chat with us directly for quick responses and instant booking assistance
          </p>
          <Button
            asChild
            size="lg"
            variant="secondary"
            className="mt-8 rounded-full"
          >
            <a
              href="https://wa.me/15551234567"
              target="_blank"
              rel="noopener noreferrer"
            >
              <MessageCircle className="h-5 w-5 mr-2" />
              Chat on WhatsApp
            </a>
          </Button>
        </div>
      </section>
    </Layout>
  );
};

export default Contact;
