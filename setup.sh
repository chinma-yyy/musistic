cd /backend/server
npm i
npm install -g typescript
tsc 


cd ../sockets
npm i
tsc

cd ../../frontend
npm install --global yarn
yarn
yarn build
