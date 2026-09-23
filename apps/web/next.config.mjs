/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['@subflow/core', '@subflow/ui'],
  reactStrictMode: true,
  poweredByHeader: false,
  devIndicators: false,
  async headers() { return [{ source: '/:path*', headers: [
    { key: 'X-Content-Type-Options', value: 'nosniff' },
    { key: 'Referrer-Policy', value: 'no-referrer' },
    { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
    { key: 'Content-Security-Policy', value: "object-src 'none'; base-uri 'self'; frame-ancestors 'self'; form-action 'self'" }
  ] }]; },
  images: {
    unoptimized: true
  }
};





export default nextConfig;
