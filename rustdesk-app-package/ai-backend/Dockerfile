FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY package*.json ./

RUN npm ci --only=production

COPY src ./src

RUN mkdir -p logs

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

EXPOSE 8080

ENV NODE_ENV=production
ENV PORT=8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

CMD ["node", "src/index.js"]