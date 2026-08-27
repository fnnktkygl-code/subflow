/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  trailingSlash: false,
  transpilePackages: ['@subflow/core', '@subflow/ui'],
  reactStrictMode: true,
  images: {
    unoptimized: true
  }
};



export default nextConfig;
