-- Ensure full row data is available for realtime on updates/deletes
ALTER TABLE public.moods REPLICA IDENTITY FULL;
ALTER TABLE public.alerts REPLICA IDENTITY FULL;