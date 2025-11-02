import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { email } = await req.json()

    if (!email) {
      console.error('Email is required')
      return new Response(
        JSON.stringify({ error: 'Email is required' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    console.log(`Looking up user with email: ${email}`)

    // Use admin API to search for user by email (case-insensitive)
    const { data: { users }, error } = await supabaseClient.auth.admin.listUsers()

    if (error) {
      console.error('Error listing users:', error)
      throw error
    }

    console.log(`Found ${users?.length || 0} total users`)

    // Case-insensitive email search
    const normalizedEmail = email.toLowerCase().trim()
    const user = users?.find(u => u.email?.toLowerCase() === normalizedEmail)

    if (!user) {
      console.log(`User not found with email: ${email}`)
      return new Response(
        JSON.stringify({ 
          error: 'User not found',
          hint: 'Make sure the user has created an account first'
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 404 }
      )
    }

    console.log(`Found user: ${user.id}`)

    return new Response(
      JSON.stringify({ user_id: user.id }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : 'Unknown error' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
