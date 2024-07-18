const express = require('express');
const { OpenAI } = require('openai');

const app = express();
const port = 3000;

app.use(express.json());

app.use(express.static('public'));

// Initialize OpenAI with your API key
const openai = new OpenAI({
    apiKey: 'YOUR OPENAI-api-key GOES HERE'
});

// Chat endpoint to handle POST requests
app.post('/chat', async (req, res) => {
    try {
        const { question } = req.body;
        if (!question) {
            return res.status(400).json({ message: 'Question is required' });
        }

        const resp = await openai.chat.completions.create({
            model: "gpt-3.5-turbo",
            messages: [
                { role: "user", content: question }
            ]
        });

        res.status(200).json({ message: resp.choices[0].message.content });
    } catch (e) {
        console.error('Error during API call:', e);
        res.status(400).json({ message: e.message });
    }
});

app.listen(port, () => {
    console.log(`Server is active on port ${port}`);
});
