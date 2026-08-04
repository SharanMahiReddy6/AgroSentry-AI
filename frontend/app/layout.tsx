import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import LayoutWrapper from "@/components/LayoutWrapper";

const inter = Inter({ subsets: ["latin"], variable: "--font-inter" });

export const metadata: Metadata = {
  title: "AgroSentry AI | Smart Crop Diagnostic Platform",
  description: "AI-powered agricultural disease detection and treatment platform for farmers.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.variable} font-sans antialiased`}>
        <div className="flex">
          {/* We only show Sidebar on non-auth pages. For simplicity, we check in layout or handle it in page. */}
          {/* In a real app, you might use a (dashboard) group. Here we will just render it and handle visibility. */}
          <AppShell>{children}</AppShell>
        </div>
      </body>
    </html>
  );
}

// Simple wrapper to handle conditional sidebar
function AppShell({ children }: { children: React.ReactNode }) {
  // We can't use usePathname in a server component, so we either make this a client component or handle it differently.
  // For this rebuild, I'll make a client-side layout wrapper.
  return <LayoutWrapper>{children}</LayoutWrapper>;
}
