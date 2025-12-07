import "./globals.css";

export const metadata = {
  title: "Next Jason",
  description: "At least JSON has only one pronunciation. JWT too, I guess?",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}