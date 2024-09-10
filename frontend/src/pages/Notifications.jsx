import { useState, useCallback, useEffect } from 'react'
import Notification from '../components/notifications/Notification'
import { useHttpClient } from '../hooks/httpRequest'

function Notifications() {
  const [newNotifications, setNewNotifications] = useState([])
  const [seenNotifications, setSeenNotifications] = useState([])
  const [allLoaded, setAllLoaded] = useState(false) // State to track if all notifications are loaded

  const { isLoading, sendRequest } = useHttpClient()

  const getNotifications = useCallback(async () => {
    try {
      const response = await sendRequest('/user/notifications/unseen')
      setNewNotifications(response.notifications)
    } catch (err) {
      console.log(err)
    }
  }, [sendRequest])

  const loadAllNotifications = useCallback(async () => {
    try {
      const response = await sendRequest('/user/notifications/all')
      setSeenNotifications(response.notifications)
      setAllLoaded(true) // Set allLoaded to true after loading all notifications
    } catch (err) {
      console.log(err)
    }
  }, [sendRequest])

  useEffect(() => {
    getNotifications()
  }, [getNotifications])

  useEffect(() => {
    const notifs = [...newNotifications]
    notifs.sort((a, b) => {
      return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    })
  }, [newNotifications])

  const noNotifications =
    newNotifications.length === 0 && seenNotifications.length === 0

  return (
    <main className="w-full h-fit pb-16 md:pb-0 md:w-4/5 lg:w-2/5 bg-rewind-dark-primary">
      <div className="p-4 text-poppins text-gray-200 text-xl border-b border-rewind-dark-tertiary">
        Notifications
      </div>
      <div>
        {isLoading && (
          <div className="p-4 text-poppins text-gray-200 text-xl border-rewind-dark-tertiary">
            Loading...
          </div>
        )}
        {noNotifications && !isLoading && (
          <div className="p-4 text-poppins text-gray-200 text-xl border-rewind-dark-tertiary">
            No new notifications
          </div>
        )}
        {newNotifications.map((notification) => (
          <Notification
            notification={notification}
            key={notification?._id}
            newNotification={true}
          />
        ))}

        {!allLoaded && (
          <div className="flex justify-center p-4">
            <button
              onClick={loadAllNotifications}
              className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-700"
            >
              Load All Notifications
            </button>
          </div>
        )}

        {seenNotifications.map((notification) => (
          <Notification
            notification={notification}
            key={notification?._id}
            newNotification={false}
          />
        ))}
      </div>
    </main>
  )
}

export default Notifications
