export interface Car {
  id: string;
  name: string;
  type: "MPV" | "SUV" | "Sedan";
  pricePerDay: number;
  capacity: number;
  transmission: "Automatic" | "Manual";
  image: string;
  featured?: boolean;
}

export const cars: Car[] = [
  {
    id: "1",
    name: "Toyota Alphard",
    type: "MPV",
    pricePerDay: 150,
    capacity: 7,
    transmission: "Automatic",
    image: "https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=800&auto=format&fit=crop&q=60",
    featured: true,
  },
  {
    id: "2",
    name: "Honda CR-V",
    type: "SUV",
    pricePerDay: 95,
    capacity: 5,
    transmission: "Automatic",
    image: "https://images.unsplash.com/photo-1568844293986-8c1a5c4fe939?w=800&auto=format&fit=crop&q=60",
    featured: true,
  },
  {
    id: "3",
    name: "Toyota Innova",
    type: "MPV",
    pricePerDay: 85,
    capacity: 7,
    transmission: "Automatic",
    image: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800&auto=format&fit=crop&q=60",
    featured: true,
  },
  {
    id: "4",
    name: "Mitsubishi Pajero",
    type: "SUV",
    pricePerDay: 120,
    capacity: 7,
    transmission: "Automatic",
    image: "https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800&auto=format&fit=crop&q=60",
    featured: true,
  },
  {
    id: "5",
    name: "Hyundai Stargazer",
    type: "MPV",
    pricePerDay: 75,
    capacity: 7,
    transmission: "Automatic",
    image: "https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800&auto=format&fit=crop&q=60",
  },
  {
    id: "6",
    name: "Mazda CX-5",
    type: "SUV",
    pricePerDay: 100,
    capacity: 5,
    transmission: "Automatic",
    image: "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&auto=format&fit=crop&q=60",
  },
  {
    id: "7",
    name: "Toyota Avanza",
    type: "MPV",
    pricePerDay: 55,
    capacity: 7,
    transmission: "Manual",
    image: "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&auto=format&fit=crop&q=60",
  },
  {
    id: "8",
    name: "Honda Civic",
    type: "Sedan",
    pricePerDay: 70,
    capacity: 5,
    transmission: "Automatic",
    image: "https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800&auto=format&fit=crop&q=60",
  },
  {
    id: "9",
    name: "Toyota Camry",
    type: "Sedan",
    pricePerDay: 90,
    capacity: 5,
    transmission: "Automatic",
    image: "https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&auto=format&fit=crop&q=60",
  },
];

export const testimonials = [
  {
    id: "1",
    name: "Sarah Johnson",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=60",
    review: "Excellent service! The car was spotless and the booking process was incredibly smooth. Will definitely use again for our family trips.",
    rating: 5,
  },
  {
    id: "2",
    name: "Michael Chen",
    avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=60",
    review: "Great selection of MPVs for our group vacation. Staff was helpful and prices were very reasonable. Highly recommended!",
    rating: 5,
  },
  {
    id: "3",
    name: "Emily Rodriguez",
    avatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=60",
    review: "The SUV we rented was perfect for our weekend adventure. Clean, reliable, and affordable. Thank you!",
    rating: 5,
  },
  {
    id: "4",
    name: "David Thompson",
    avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=60",
    review: "24/7 support really came through when we needed help. Professional team and well-maintained vehicles.",
    rating: 5,
  },
];
