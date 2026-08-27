import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      return NextResponse.json(
        { error: 'Clé API Gemini non configurée dans le serveur.' },
        { status: 500 }
      );
    }

    const body = await req.json();
    const { imageBase64, mimeType = 'image/jpeg', textPrompt } = body;

    const promptText = `
Tu es un expert en gestion financière d'abonnements pour l'application SubFlow.
Analyse cette facture, ce reçu bancaire ou cette description d'abonnement et extrais avec précision les informations suivantes en JSON strict :
- serviceName: nom propre du service (ex: "Netflix", "Spotify", "Canal+", "Basic-Fit", "iCloud", "ChatGPT")
- price: montant numérique du prélèvement (ex: 13.49)
- currency: code ISO de la devise (ex: "EUR", "USD", "GBP")
- cycle: périodicité ("monthly", "yearly", "weekly", "quarterly")
- renewalDate: date du prochain débit ou de la facture au format YYYY-MM-DD (si l'année n'est pas précisée, utilise 2026)
- category: catégorie ("Streaming", "Musique", "Productivité", "Sport", "Jeux", "Cloud", "Autre")
- confidenceScore: indice de confiance entre 0.0 et 1.0

${textPrompt ? `Texte fourni : "${textPrompt}"` : ''}
`;

    const parts: any[] = [{ text: promptText }];

    if (imageBase64) {
      const cleanBase64 = imageBase64.replace(/^data:image\/[a-zA-Z]+;base64,/, '');
      parts.push({
        inlineData: {
          mimeType,
          data: cleanBase64,
        },
      });
    }

    const payload = {
      contents: [{ parts }],
      generationConfig: {
        responseMimeType: 'application/json',
        responseSchema: {
          type: 'OBJECT',
          properties: {
            serviceName: { type: 'STRING' },
            price: { type: 'NUMBER' },
            currency: { type: 'STRING' },
            cycle: { type: 'STRING' },
            renewalDate: { type: 'STRING' },
            category: { type: 'STRING' },
            confidenceScore: { type: 'NUMBER' },
          },
          required: ['serviceName', 'price', 'currency', 'cycle', 'renewalDate', 'category'],
        },
      },
    };

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      return NextResponse.json(
        { error: `Erreur Gemini API (${response.status}): ${errorText}` },
        { status: response.status }
      );
    }

    const data = await response.json();
    const resultText = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!resultText) {
      return NextResponse.json(
        { error: "L'IA n'a pas pu extraire de données de ce document." },
        { status: 422 }
      );
    }

    const parsedJson = JSON.parse(resultText);
    return NextResponse.json({ success: true, data: parsedJson });
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Erreur interne lors du traitement du document.' },
      { status: 500 }
    );
  }
}
