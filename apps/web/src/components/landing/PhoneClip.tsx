'use client';
import React, { useEffect, useRef } from 'react';

// A real SubFlow screen recording (fictitious data) in a phone frame.
// Nothing downloads before the clip is on screen; it plays only while visible
// (and while `active`), restarts when it becomes active, and never autoplays
// for people who asked for reduced motion.
export function PhoneClip({ name, label, active = true, className = '' }: {
  name: string; label: string; active?: boolean; className?: string;
}) {
  const ref = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    const video = ref.current;
    if (!video) return;
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) { video.controls = true; return; }
    let visible = false;
    const sync = () => { if (visible && active) video.play().catch(() => {}); else video.pause(); };
    const io = new IntersectionObserver((entries) => { visible = entries.some((e) => e.isIntersecting); sync(); }, { threshold: 0.35 });
    io.observe(video);
    if (active) video.currentTime = 0;
    sync();
    return () => { io.disconnect(); video.pause(); };
  }, [active]);

  return (
    <div className={`lp-phone ${className}`}>
      <video ref={ref} src={`/landing/${name}.mp4`} poster={`/landing/${name}.webp`}
        muted loop playsInline preload="none" aria-label={label} />
    </div>
  );
}
