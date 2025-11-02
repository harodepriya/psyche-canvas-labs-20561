
-- Migration: 20251003031740
-- Create profiles table for user data
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create journals table
CREATE TABLE public.journals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  sentiment TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create moods table
CREATE TABLE public.moods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  mood TEXT NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create goals table
CREATE TABLE public.goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  target_date DATE,
  progress INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create chat_messages table
CREATE TABLE public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create inspiration_boards table
CREATE TABLE public.inspiration_boards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create inspiration_items table
CREATE TABLE public.inspiration_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  board_id UUID REFERENCES public.inspiration_boards(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  title TEXT,
  notes TEXT,
  is_favorite BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inspiration_boards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inspiration_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- RLS Policies for journals
CREATE POLICY "Users can view their own journals"
  ON public.journals FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own journals"
  ON public.journals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own journals"
  ON public.journals FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own journals"
  ON public.journals FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for moods
CREATE POLICY "Users can view their own moods"
  ON public.moods FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own moods"
  ON public.moods FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own moods"
  ON public.moods FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for goals
CREATE POLICY "Users can view their own goals"
  ON public.goals FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own goals"
  ON public.goals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goals"
  ON public.goals FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goals"
  ON public.goals FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for chat_messages
CREATE POLICY "Users can view their own chat messages"
  ON public.chat_messages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own chat messages"
  ON public.chat_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own chat messages"
  ON public.chat_messages FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for inspiration_boards
CREATE POLICY "Users can view their own boards"
  ON public.inspiration_boards FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own boards"
  ON public.inspiration_boards FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own boards"
  ON public.inspiration_boards FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own boards"
  ON public.inspiration_boards FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for inspiration_items
CREATE POLICY "Users can view their own inspiration items"
  ON public.inspiration_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own inspiration items"
  ON public.inspiration_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own inspiration items"
  ON public.inspiration_items FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own inspiration items"
  ON public.inspiration_items FOR DELETE
  USING (auth.uid() = user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_journals_updated_at
  BEFORE UPDATE ON public.journals
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_goals_updated_at
  BEFORE UPDATE ON public.goals
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_inspiration_boards_updated_at
  BEFORE UPDATE ON public.inspiration_boards
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Migration: 20251005055153
-- Create role enum
CREATE TYPE public.app_role AS ENUM ('user', 'parent', 'guardian', 'police', 'admin');

-- Create user_roles table
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Create monitoring relationships table (links guardians to monitored users)
CREATE TABLE public.monitoring_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  monitor_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  monitored_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  relationship_type TEXT NOT NULL, -- 'parent', 'guardian', 'police', etc.
  approved BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (monitor_id, monitored_user_id)
);

ALTER TABLE public.monitoring_relationships ENABLE ROW LEVEL SECURITY;

-- Security definer function to check if user has a specific role
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;

-- Security definer function to check if user can monitor another user
CREATE OR REPLACE FUNCTION public.can_monitor(_monitor_id UUID, _monitored_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.monitoring_relationships
    WHERE monitor_id = _monitor_id
      AND monitored_user_id = _monitored_user_id
      AND approved = true
  )
$$;

-- RLS policies for user_roles
CREATE POLICY "Users can view their own roles"
ON public.user_roles
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all roles"
ON public.user_roles
FOR SELECT
USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can insert roles"
ON public.user_roles
FOR INSERT
WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- RLS policies for monitoring_relationships
CREATE POLICY "Users can view their monitoring relationships"
ON public.monitoring_relationships
FOR SELECT
USING (auth.uid() = monitor_id OR auth.uid() = monitored_user_id);

CREATE POLICY "Monitors can create monitoring relationships"
ON public.monitoring_relationships
FOR INSERT
WITH CHECK (
  auth.uid() = monitor_id AND 
  (public.has_role(auth.uid(), 'parent') OR 
   public.has_role(auth.uid(), 'guardian') OR 
   public.has_role(auth.uid(), 'police') OR 
   public.has_role(auth.uid(), 'admin'))
);

CREATE POLICY "Users can approve monitoring relationships"
ON public.monitoring_relationships
FOR UPDATE
USING (auth.uid() = monitored_user_id)
WITH CHECK (auth.uid() = monitored_user_id);

CREATE POLICY "Admins can manage all monitoring relationships"
ON public.monitoring_relationships
FOR ALL
USING (public.has_role(auth.uid(), 'admin'));

-- Update RLS policies for moods table
DROP POLICY IF EXISTS "Users can view their own moods" ON public.moods;
CREATE POLICY "Users can view their own moods"
ON public.moods
FOR SELECT
USING (
  auth.uid() = user_id OR 
  public.can_monitor(auth.uid(), user_id) OR
  public.has_role(auth.uid(), 'admin')
);

-- Update RLS policies for journals table
DROP POLICY IF EXISTS "Users can view their own journals" ON public.journals;
CREATE POLICY "Users can view their own journals"
ON public.journals
FOR SELECT
USING (
  auth.uid() = user_id OR 
  public.can_monitor(auth.uid(), user_id) OR
  public.has_role(auth.uid(), 'admin')
);

-- Update RLS policies for chat_messages table
DROP POLICY IF EXISTS "Users can view their own chat messages" ON public.chat_messages;
CREATE POLICY "Users can view their own chat messages"
ON public.chat_messages
FOR SELECT
USING (
  auth.uid() = user_id OR 
  public.can_monitor(auth.uid(), user_id) OR
  public.has_role(auth.uid(), 'admin')
);

-- Update RLS policies for goals table
DROP POLICY IF EXISTS "Users can view their own goals" ON public.goals;
CREATE POLICY "Users can view their own goals"
ON public.goals
FOR SELECT
USING (
  auth.uid() = user_id OR 
  public.can_monitor(auth.uid(), user_id) OR
  public.has_role(auth.uid(), 'admin')
);

-- Update RLS policies for profiles table
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile"
ON public.profiles
FOR SELECT
USING (
  auth.uid() = user_id OR 
  public.can_monitor(auth.uid(), user_id) OR
  public.has_role(auth.uid(), 'admin')
);

-- Migration: 20251008051453
-- First, create profiles for any existing users that don't have one
INSERT INTO public.profiles (user_id, display_name)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'name', au.email)
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = au.id
);

-- Drop existing foreign key constraints if they exist
ALTER TABLE public.monitoring_relationships
  DROP CONSTRAINT IF EXISTS monitoring_relationships_monitor_id_fkey;

ALTER TABLE public.monitoring_relationships
  DROP CONSTRAINT IF EXISTS monitoring_relationships_monitored_user_id_fkey;

-- Add foreign key constraints to profiles table
ALTER TABLE public.monitoring_relationships
  ADD CONSTRAINT monitoring_relationships_monitor_id_fkey 
  FOREIGN KEY (monitor_id) 
  REFERENCES public.profiles(user_id) 
  ON DELETE CASCADE;

ALTER TABLE public.monitoring_relationships
  ADD CONSTRAINT monitoring_relationships_monitored_user_id_fkey 
  FOREIGN KEY (monitored_user_id) 
  REFERENCES public.profiles(user_id) 
  ON DELETE CASCADE;

-- Create function to automatically create profile for new users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (user_id, display_name)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
  );
  RETURN NEW;
END;
$$;

-- Drop trigger if it exists and recreate it
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Migration: 20251008051510
-- Create function to handle new user profile creation (if not exists)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (user_id, display_name)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
  )
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Drop trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger to automatically create profile for new users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Create profiles for existing users that don't have one
INSERT INTO public.profiles (user_id, display_name)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'name', email)
FROM auth.users
WHERE id NOT IN (SELECT user_id FROM public.profiles);

-- Migration: 20251009054103
-- Allow users to insert their own roles for monitoring purposes
CREATE POLICY "Users can insert their own monitoring roles"
ON public.user_roles
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = user_id 
  AND role IN ('parent', 'guardian', 'police')
);

-- Allow users to view and manage their own non-admin roles
CREATE POLICY "Users can delete their own monitoring roles"
ON public.user_roles
FOR DELETE
TO authenticated
USING (
  auth.uid() = user_id 
  AND role IN ('parent', 'guardian', 'police')
);

-- Migration: 20251101132950
-- Create alerts table for monitoring suspicious content
CREATE TABLE public.alerts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  content_type TEXT NOT NULL,
  content_id UUID NOT NULL,
  flagged_words TEXT[] NOT NULL,
  content_snippet TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  resolved BOOLEAN DEFAULT false,
  resolved_by UUID,
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- Enable RLS
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;

-- Monitors can view alerts for users they monitor
CREATE POLICY "Monitors can view alerts for monitored users"
ON public.alerts
FOR SELECT
USING (can_monitor(auth.uid(), user_id) OR has_role(auth.uid(), 'admin'::app_role));

-- Monitors can update alerts (mark as resolved)
CREATE POLICY "Monitors can update alerts"
ON public.alerts
FOR UPDATE
USING (can_monitor(auth.uid(), user_id) OR has_role(auth.uid(), 'admin'::app_role));

-- Create index for faster queries
CREATE INDEX idx_alerts_user_id ON public.alerts(user_id);
CREATE INDEX idx_alerts_resolved ON public.alerts(resolved);

-- Function to check for suspicious words
CREATE OR REPLACE FUNCTION check_suspicious_content()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  suspicious_words TEXT[] := ARRAY['suicide', 'kill', 'die', 'death', 'harm', 'hurt', 'end it', 'give up', 'no point'];
  found_words TEXT[] := ARRAY[]::TEXT[];
  word TEXT;
  content_text TEXT;
BEGIN
  -- Get content based on table
  IF TG_TABLE_NAME = 'journals' THEN
    content_text := NEW.title || ' ' || NEW.content;
  ELSIF TG_TABLE_NAME = 'chat_messages' THEN
    content_text := NEW.content;
  ELSIF TG_TABLE_NAME = 'moods' THEN
    content_text := COALESCE(NEW.note, '');
  END IF;

  -- Check for suspicious words
  FOREACH word IN ARRAY suspicious_words
  LOOP
    IF LOWER(content_text) LIKE '%' || word || '%' THEN
      found_words := array_append(found_words, word);
    END IF;
  END LOOP;

  -- Create alert if suspicious words found
  IF array_length(found_words, 1) > 0 THEN
    INSERT INTO public.alerts (user_id, content_type, content_id, flagged_words, content_snippet)
    VALUES (
      NEW.user_id,
      TG_TABLE_NAME,
      NEW.id,
      found_words,
      LEFT(content_text, 200)
    );
  END IF;

  RETURN NEW;
END;
$$;

-- Create triggers for journals, chat_messages, and moods
CREATE TRIGGER check_journals_content
AFTER INSERT OR UPDATE ON public.journals
FOR EACH ROW
EXECUTE FUNCTION check_suspicious_content();

CREATE TRIGGER check_chat_content
AFTER INSERT OR UPDATE ON public.chat_messages
FOR EACH ROW
EXECUTE FUNCTION check_suspicious_content();

CREATE TRIGGER check_mood_content
AFTER INSERT OR UPDATE ON public.moods
FOR EACH ROW
EXECUTE FUNCTION check_suspicious_content();

-- Migration: 20251102164442
-- Enable realtime for moods table
ALTER PUBLICATION supabase_realtime ADD TABLE public.moods;

-- Create storage bucket for inspiration images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('inspiration-images', 'inspiration-images', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage policies for inspiration images
CREATE POLICY "Users can upload their own inspiration images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'inspiration-images' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view their own inspiration images"
ON storage.objects FOR SELECT
USING (bucket_id = 'inspiration-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own inspiration images"
ON storage.objects FOR DELETE
USING (bucket_id = 'inspiration-images' AND auth.uid()::text = (storage.foldername(name))[1]);
