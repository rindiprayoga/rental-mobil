

## Car Rental Website - Implementation Plan

### Overview
A professional, family-oriented car rental website with a friendly and rounded design aesthetic, built as a multi-page responsive application with mobile-first priority.

---

### Design System
- **Primary Background:** White
- **Accent Color:** Orange (for buttons, highlights, and CTAs)
- **Text Color:** Black/dark gray
- **Style:** Rounded corners, soft shadows, approachable typography
- **Responsiveness:** Mobile-first design approach

---

### Pages & Features

#### 1. Home Page
- **Header (shared across all pages)**
  - Logo on the left
  - Navigation menu: Home, About Us, Car Catalog, How to Order, Contact
  - Mobile hamburger menu for smaller screens
  - Prominent orange "Book Now" button

- **Hero Section**
  - Full-width background image of a featured MPV/SUV
  - Overlay with headline: "Easy & Reliable Car Rental"
  - Subheadline about vehicle variety
  - "View All Cars" CTA button

- **Featured Cars Preview**
  - 3-4 highlighted MPVs and SUVs
  - Quick link to full catalog

- **Benefits Section**
  - 4 benefit cards with icons: Affordable Price, Well-Maintained Cars, Easy Process, 24/7 Service

- **How to Order Section**
  - 4-step horizontal process with icons and descriptions
  - Responsive: stacks vertically on mobile

- **Testimonials Section**
  - Customer reviews with avatars and names
  - Carousel or grid layout

#### 2. About Us Page
- Company story and mission
- Team values
- Why choose us section

#### 3. Car Catalog Page
- **Filter Sidebar/Bar**
  - Filter by price range, car type (MPV, SUV, Sedan), capacity
- **Car Grid**
  - Car image, name, type, price per day
  - "View Details" button on each card
  - Emphasis on MPVs and SUVs (shown first/prominently)
  - Few sedans at the bottom

#### 4. How to Order Page
- Detailed step-by-step guide
- FAQ section about the rental process
- Link to booking form

#### 5. Contact Page
- Contact information (address, WhatsApp, email)
- Contact form
- Map placeholder
- Business hours

#### 6. Booking Section (accessible from multiple pages)
- Simple reservation form
- Fields: Name, Contact Info (phone/WhatsApp), Car Selection dropdown, Pickup Date, Return Date
- Submit button with confirmation message

---

### Shared Components
- **Header:** Sticky navigation with mobile menu
- **Footer:** Contact info, quick links, social media icons
- **Car Card:** Reusable component for catalog and featured sections
- **CTA Buttons:** Consistent orange rounded buttons throughout

---

### Mock Data
- 8-10 sample cars (6 MPVs/SUVs, 2-3 sedans)
- 4-5 customer testimonials
- Placeholder images from Unsplash

---

### Technical Notes
- Built with React + TypeScript
- Styled with Tailwind CSS (rounded corners, mobile-first)
- React Router for multi-page navigation
- No backend required - all mock data stored in frontend

