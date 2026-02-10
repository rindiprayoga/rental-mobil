import { Link } from "react-router-dom";
import { Car, Phone, Mail, MapPin, Facebook, Instagram, Twitter } from "lucide-react";

const Footer = () => {
  return (
    <footer className="bg-foreground text-background">
      <div className="container py-12 md:py-16">
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
          {/* Brand */}
          <div className="space-y-4">
            <Link to="/" className="flex items-center gap-2">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary">
                <Car className="h-5 w-5 text-primary-foreground" />
              </div>
              <span className="text-xl font-bold">RentDrive</span>
            </Link>
            <p className="text-sm text-background/70">
              Your trusted partner for reliable and affordable car rentals. 
              Making every journey memorable since 2015.
            </p>
          </div>

          {/* Quick Links */}
          <div className="space-y-4">
            <h4 className="text-lg font-semibold">Quick Links</h4>
            <nav className="flex flex-col gap-2">
              <Link to="/" className="text-sm text-background/70 hover:text-primary transition-colors">
                Home
              </Link>
              <Link to="/about" className="text-sm text-background/70 hover:text-primary transition-colors">
                About Us
              </Link>
              <Link to="/catalog" className="text-sm text-background/70 hover:text-primary transition-colors">
                Car Catalog
              </Link>
              <Link to="/how-to-order" className="text-sm text-background/70 hover:text-primary transition-colors">
                How to Order
              </Link>
              <Link to="/contact" className="text-sm text-background/70 hover:text-primary transition-colors">
                Contact
              </Link>
            </nav>
          </div>

          {/* Contact Info */}
          <div className="space-y-4">
            <h4 className="text-lg font-semibold">Contact Us</h4>
            <div className="space-y-3">
              <div className="flex items-center gap-3 text-sm text-background/70">
                <MapPin className="h-4 w-4 text-primary" />
                <span>123 Main Street, Downtown, City 12345</span>
              </div>
              <div className="flex items-center gap-3 text-sm text-background/70">
                <Phone className="h-4 w-4 text-primary" />
                <span>+1 (555) 123-4567</span>
              </div>
              <div className="flex items-center gap-3 text-sm text-background/70">
                <Mail className="h-4 w-4 text-primary" />
                <span>hello@rentdrive.com</span>
              </div>
            </div>
          </div>

          {/* Social Media */}
          <div className="space-y-4">
            <h4 className="text-lg font-semibold">Follow Us</h4>
            <div className="flex gap-4">
              <a
                href="#"
                className="flex h-10 w-10 items-center justify-center rounded-full bg-background/10 hover:bg-primary transition-colors"
              >
                <Facebook className="h-5 w-5" />
              </a>
              <a
                href="#"
                className="flex h-10 w-10 items-center justify-center rounded-full bg-background/10 hover:bg-primary transition-colors"
              >
                <Instagram className="h-5 w-5" />
              </a>
              <a
                href="#"
                className="flex h-10 w-10 items-center justify-center rounded-full bg-background/10 hover:bg-primary transition-colors"
              >
                <Twitter className="h-5 w-5" />
              </a>
            </div>
            <p className="text-sm text-background/70">
              Open daily: 8:00 AM - 10:00 PM
            </p>
          </div>
        </div>

        <div className="mt-12 border-t border-background/20 pt-8 text-center">
          <p className="text-sm text-background/50">
            © {new Date().getFullYear()} RentDrive. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
