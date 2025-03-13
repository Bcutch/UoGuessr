// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js"

console.log("Hello from Functions!")

Deno.serve(async (req) => {
  // TOOD: Connect to the supabase database

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
  );

  // Get 5 pictures for the daily game
  const { data: pictures, error } = await supabase.rpc("get_random_pictures", {
    count: 5,
  });


  console.log('pictures = ', pictures);
  if (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }

  // Create a new daily game
  const { status: gameStatus, error: gameStatusError } = await supabase
    .from("games")
    .insert({
      mode: "daily",
      valid_from: new Date(),
      valid_until: new Date(new Date().getTime() + 24 * 60 * 60 * 1000),
    });

  console.log('game status = ', gameStatus);
  if (gameStatusError || gameStatus !== 201) {
    console.error(gameStatusError);
    return new Response(JSON.stringify({ error: gameStatusError.message }), {
      status: 500,
    });
  }
  
  // Get the newest game in the game table
  const { status: gameFetchStatus, data: game, error: gameError } = await supabase
    .from("games")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(1);

  console.log('game = ', game);
  if (gameError || gameFetchStatus !== 200) {
    console.error(gameError);
    return new Response(JSON.stringify({ error: gameError.message }), {
      status: 500,
    });
  }
  // Add the 5 pictures to the daily game (game_pictures table)
  const { status: gamePicturesStatus, error: gamePicturesError } = await supabase
    .from("game_pictures")
    .insert(pictures.map((picture, index) => ({ game_id: game[0].game_id, picture_id: picture.picture_id, sequence_number: index })));

  console.log('gamePicturesStatus = ', gamePicturesStatus);
  if (gamePicturesError || gamePicturesStatus !== 201) {
    console.error(gamePicturesError);
    return new Response(JSON.stringify({ error: gamePicturesError.message }), {
      status: 500,
    });
  }

  // Return the daily game id
  return new Response(JSON.stringify({ gameId: game[0].id }), {
    headers: { "Content-Type": "application/json" },
  });
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/daily-game' \
    --header 'Authorization: Bearer <your-anon-key>' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
