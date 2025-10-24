FROM node:18.9.1

WORKDIR /app

COPY . .

RUN npm install 

EXPOSE 5000

CMD ["npm", "run", "dev" ]

