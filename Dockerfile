FROM node:24-alpine

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY src/ ./src/

USER 1000
ENV PORT=8000
EXPOSE 8000
CMD ["node", "src/app.js"]
