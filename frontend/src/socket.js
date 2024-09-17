import { io } from 'socket.io-client'

export const chatSocket = io(import.meta.env.VITE_SOCKET_ENDPOINT + '/chat', {
  autoConnect: false,
  extraHeaders: {
    Authorization: `Bearer ${localStorage.getItem('token')}`,
  },
  transports: ['websocket'],
  query: {
    token: localStorage.getItem('token'),
  },
})

export const mainSocket = io(import.meta.env.VITE_SOCKET_ENDPOINT, {
  autoConnect: false,
  extraHeaders: {
    Authorization: `Bearer ${localStorage.getItem('token')}`,
  },
  transports: ['websocket'],
  query: {
    token: localStorage.getItem('token'),
  },
})
