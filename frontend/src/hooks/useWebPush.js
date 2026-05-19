import { useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import api from '../api/client';

function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
  const raw = window.atob(base64);
  return new Uint8Array([...raw].map((c) => c.charCodeAt(0)));
}

export function useWebPush() {
  const { user } = useAuth();

  useEffect(() => {
    if (!user) return;
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) return;

    let cancelled = false;

    async function setup() {
      try {
        const { data } = await api.get('/notifications/vapid-public-key');
        if (cancelled || !data?.publicKey) return;

        const reg = await navigator.serviceWorker.register('/sw.js');
        await navigator.serviceWorker.ready;

        const permission = await Notification.requestPermission();
        if (cancelled || permission !== 'granted') return;

        const existing = await reg.pushManager.getSubscription();
        const sub = existing ?? await reg.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: urlBase64ToUint8Array(data.publicKey),
        });

        if (cancelled) return;

        await api.post('/notifications/push-token', {
          token: JSON.stringify(sub.toJSON()),
          platform: 'web',
        });
      } catch (err) {
        if (!cancelled) console.warn('[WebPush] setup failed:', err?.message);
      }
    }

    setup();
    return () => { cancelled = true; };
  }, [user?.id]);
}
