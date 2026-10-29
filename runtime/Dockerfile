# The image of the shared backend. Build it from this folder:
#   docker build -t calaverita-runtime runtime
FROM node:22-slim

WORKDIR /app
ENV NODE_ENV=production

# `npm start` runs the TypeScript with tsx, a dev dependency, so install all of them.
COPY package.json package-lock.json ./
RUN npm ci --include=dev --no-audit --no-fund

COPY server.ts env.ts gate.ts ./

USER node
# Cloud Run sets PORT; server.ts reads it and listens on 0.0.0.0.
CMD ["npm", "start", "--silent"]
