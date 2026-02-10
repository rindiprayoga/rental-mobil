import { Link } from "react-router-dom";
import { Car, FileText, CreditCard, CheckCircle, HelpCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import Layout from "@/components/Layout";

const steps = [
  {
    icon: Car,
    number: "01",
    title: "Choose Your Vehicle",
    description:
      "Browse our extensive catalog of MPVs, SUVs, and sedans. Use filters to find the perfect car based on your needs, budget, and preferences. Compare prices and features to make the best choice.",
  },
  {
    icon: FileText,
    number: "02",
    title: "Fill Out the Booking Form",
    description:
      "Provide your personal details, contact information (phone/WhatsApp), preferred pickup date and time, and any special requirements. Our simple form takes just a few minutes to complete.",
  },
  {
    icon: CreditCard,
    number: "03",
    title: "Confirm & Make Payment",
    description:
      "Review your booking details and confirm your reservation. We accept various payment methods including bank transfer and cash. A deposit may be required for certain vehicles.",
  },
  {
    icon: CheckCircle,
    number: "04",
    title: "Pick Up & Enjoy",
    description:
      "Arrive at our pickup location at your scheduled time. Our staff will guide you through a quick vehicle inspection, hand over the keys, and you're ready to hit the road!",
  },
];

const faqs = [
  {
    question: "What documents do I need to rent a car?",
    answer:
      "You'll need a valid driver's license, a government-issued ID (passport or national ID), and a credit/debit card for the security deposit. International visitors should also bring their international driving permit.",
  },
  {
    question: "How far in advance should I book?",
    answer:
      "We recommend booking at least 2-3 days in advance to ensure availability, especially for popular vehicles like MPVs during weekends and holidays. However, we also accept same-day bookings based on availability.",
  },
  {
    question: "What is included in the rental price?",
    answer:
      "Our rental prices include basic insurance coverage, regular maintenance, and 24/7 roadside assistance. Fuel is not included – you'll receive the car with a full tank and should return it the same way.",
  },
  {
    question: "Can I extend my rental period?",
    answer:
      "Yes! Simply contact us via WhatsApp or phone at least 24 hours before your original return time. Extensions are subject to vehicle availability and will be charged at the daily rate.",
  },
  {
    question: "What happens if the car breaks down?",
    answer:
      "We provide 24/7 roadside assistance. If you experience any issues, call our emergency hotline immediately. We'll either send a technician or provide a replacement vehicle at no extra cost.",
  },
  {
    question: "Is there a mileage limit?",
    answer:
      "Most of our rentals include unlimited mileage for local use. For specific vehicles or long-distance trips, additional terms may apply. Please check your rental agreement for details.",
  },
  {
    question: "Can I cancel or modify my booking?",
    answer:
      "Cancellations made 48+ hours before pickup receive a full refund. Cancellations within 48 hours may incur a fee. Modifications are free when made 24+ hours in advance, subject to availability.",
  },
];

const HowToOrder = () => {
  return (
    <Layout>
      {/* Hero */}
      <section className="bg-gradient-to-br from-secondary to-background py-16 md:py-24">
        <div className="container">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-4xl font-bold text-foreground md:text-5xl">
              How to <span className="text-primary">Rent a Car</span>
            </h1>
            <p className="mt-6 text-lg text-muted-foreground">
              Renting a car with us is simple and straightforward. Follow these 
              easy steps to get on the road in no time.
            </p>
          </div>
        </div>
      </section>

      {/* Steps */}
      <section className="py-16 md:py-24 bg-background">
        <div className="container">
          <div className="max-w-4xl mx-auto">
            <div className="space-y-12">
              {steps.map((step, index) => (
                <div
                  key={index}
                  className="flex flex-col md:flex-row gap-6 items-start"
                >
                  <div className="flex-shrink-0">
                    <div className="relative">
                      <div className="flex h-20 w-20 items-center justify-center rounded-full bg-primary text-primary-foreground">
                        <step.icon className="h-10 w-10" />
                      </div>
                      <span className="absolute -top-2 -right-2 flex h-8 w-8 items-center justify-center rounded-full bg-foreground text-background text-sm font-bold">
                        {step.number}
                      </span>
                    </div>
                  </div>
                  <Card className="flex-1 border-0 shadow-md">
                    <CardHeader>
                      <CardTitle className="text-xl">{step.title}</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <p className="text-muted-foreground">{step.description}</p>
                    </CardContent>
                  </Card>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="py-16 md:py-24 bg-secondary">
        <div className="container">
          <div className="max-w-3xl mx-auto">
            <div className="text-center mb-12">
              <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
                <HelpCircle className="h-8 w-8 text-primary" />
              </div>
              <h2 className="text-3xl font-bold text-foreground md:text-4xl">
                Frequently Asked Questions
              </h2>
              <p className="mt-3 text-muted-foreground">
                Got questions? We've got answers.
              </p>
            </div>
            <Accordion type="single" collapsible className="space-y-4">
              {faqs.map((faq, index) => (
                <AccordionItem
                  key={index}
                  value={`item-${index}`}
                  className="bg-background rounded-xl px-6 border-0 shadow-sm"
                >
                  <AccordionTrigger className="text-left hover:no-underline">
                    {faq.question}
                  </AccordionTrigger>
                  <AccordionContent className="text-muted-foreground">
                    {faq.answer}
                  </AccordionContent>
                </AccordionItem>
              ))}
            </Accordion>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-16 md:py-24 bg-primary">
        <div className="container text-center">
          <h2 className="text-3xl font-bold text-primary-foreground md:text-4xl">
            Ready to Book Your Car?
          </h2>
          <p className="mt-4 text-primary-foreground/80 max-w-2xl mx-auto">
            Start your booking now and enjoy a hassle-free rental experience
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center mt-8">
            <Button asChild size="lg" variant="secondary" className="rounded-full">
              <Link to="/contact">Book Now</Link>
            </Button>
            <Button
              asChild
              size="lg"
              variant="outline"
              className="rounded-full bg-transparent text-primary-foreground border-primary-foreground hover:bg-primary-foreground hover:text-primary"
            >
              <Link to="/catalog">View Cars</Link>
            </Button>
          </div>
        </div>
      </section>
    </Layout>
  );
};

export default HowToOrder;
