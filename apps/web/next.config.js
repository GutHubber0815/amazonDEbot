/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@early-help/api-client', '@early-help/types', '@early-help/utils'],
};

module.exports = nextConfig;
