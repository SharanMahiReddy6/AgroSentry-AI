import type { NextConfig } from "next";

const isExport = process.env.OUTPUT_EXPORT === 'true' || process.env.GITHUB_ACTIONS === 'true';
const basePath = process.env.NEXT_PUBLIC_BASE_PATH || '';

const nextConfig: NextConfig = {
  output: 'export',
  images: {
    unoptimized: true,
  },
  ...(basePath ? { basePath, assetPrefix: basePath } : {}),
  trailingSlash: true,
};

export default nextConfig;
