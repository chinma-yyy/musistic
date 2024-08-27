FROM node:18

WORKDIR /app

COPY package*.json /app

RUN npm install

RUN npm install -g typescript

COPY . /app

EXPOSE 3001

CMD ["npm","run" ,"dev:prod"]