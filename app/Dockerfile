FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8000
CMD ["node", "index.js"]
#this is a simple Dockerfile for a Node.js application.