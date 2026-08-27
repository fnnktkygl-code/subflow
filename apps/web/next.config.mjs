/** @type {import('next').NextConfig} */
const nextConfig = {
  trailingSlash: false,
  transpilePackages: ['@subflow/core', '@subflow/ui'],
  reactStrictMode: true,
  images: {
    unoptimized: true
  }
};


export default nextConfig;
