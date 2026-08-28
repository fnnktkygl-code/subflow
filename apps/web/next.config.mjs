/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['@subflow/core', '@subflow/ui'],
  reactStrictMode: true,
  images: {
    unoptimized: true
  }
};





export default nextConfig;
