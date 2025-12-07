FROM node:24-bookworm AS base


FROM base AS builder
WORKDIR /app

COPY package*.json .
RUN npm install

COPY . .
RUN npm run build


FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

ENV API_URL=http://backend:8000

CMD node server.js