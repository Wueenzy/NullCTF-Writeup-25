FROM node:18-alpine

WORKDIR /app
COPY package.json ./

RUN npm install

COPY next.config.mjs ./
COPY jsconfig.json ./
COPY middleware.js ./
COPY app/ ./app/

RUN apk add --no-cache openssl && \
    openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048 && \
    openssl rsa -pubout -in private.pem -out public.pem;

RUN npm run build

ENV NODE_ENV=production
ENV INVITE_CODE=secret_invite_code
ENV FLAG=nullctf{fake_flag}

EXPOSE 3000

CMD ["npm", "start"]