import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

import { BrowserRouter } from 'react-router-dom'

import AuthContextProvider from './store/authContext'

ReactDOM.createRoot(document.getElementById('root')).render(
  <AuthContextProvider>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </AuthContextProvider>
)
