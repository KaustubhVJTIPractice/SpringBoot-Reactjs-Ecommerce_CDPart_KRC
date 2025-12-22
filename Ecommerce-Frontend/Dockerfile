# =========================
# Build Stage
# =========================
FROM node:18-alpine AS build
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy source and build
COPY . .
RUN npm run build


# =========================
# Runtime Stage
# =========================
FROM nginx:alpine

# Copy Vite build output
COPY --from=build /app/dist /usr/share/nginx/html

# Expose web port
EXPOSE 80

# Start Nginx
CMD ["nginx","-g","daemon off;"]
