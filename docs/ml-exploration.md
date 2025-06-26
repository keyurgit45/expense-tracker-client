# On-Device ML for SMS Classification

## Option 1: TensorFlow Lite Flutter

### Installation
```yaml
dependencies:
  tflite_flutter: ^0.10.4
  tflite_flutter_helper: ^0.4.2
```

### Approach
1. Train a text classification model (using Python/TensorFlow)
2. Convert to TFLite format
3. Embed model in Flutter app
4. Run inference on-device

### Example Implementation
```dart
import 'package:tflite_flutter/tflite_flutter.dart';

class SmsClassifier {
  late Interpreter _interpreter;
  late Map<String, int> _wordIndex;
  
  Future<void> loadModel() async {
    // Load model
    _interpreter = await Interpreter.fromAsset('assets/ml/sms_classifier.tflite');
    
    // Load word index for tokenization
    final wordIndexJson = await rootBundle.loadString('assets/ml/word_index.json');
    _wordIndex = Map<String, int>.from(json.decode(wordIndexJson));
  }
  
  Future<Map<String, double>> classifySms(String text) async {
    // Tokenize and pad text
    final input = _preprocessText(text);
    
    // Run inference
    final output = List.filled(1 * 4, 0.0).reshape([1, 4]); // 4 classes
    _interpreter.run(input, output);
    
    // Return probabilities
    return {
      'isTransaction': output[0][0],
      'transactionType': output[0][1], // credit/debit
      'paymentMethod': output[0][2], // upi/card/etc
      'confidence': output[0][3],
    };
  }
}
```

## Option 2: Google ML Kit

### Installation
```yaml
dependencies:
  google_mlkit_text_recognition: ^0.11.0
  google_mlkit_entity_extraction: ^0.11.0
  google_mlkit_smart_reply: ^0.11.0
```

### Limitations
- No direct text classification API
- Would need to use entity extraction for detecting amounts, dates
- Better for OCR/text extraction than classification

## Option 3: Hybrid Approach - Rule-Based + ML

### Current Implementation Enhancement
```dart
class SmartSmsParser {
  final SmsParser _ruleBasedParser;
  final SmsClassifier _mlClassifier;
  
  Future<SmsTransaction> parseWithML(String smsBody) async {
    // First, use rule-based parser
    final ruleBasedResult = _ruleBasedParser.parse(smsBody);
    
    // Then, use ML for confidence and additional extraction
    final mlPredictions = await _mlClassifier.classifySms(smsBody);
    
    // Combine results
    if (mlPredictions['confidence']! > 0.8) {
      return _enhanceWithML(ruleBasedResult, mlPredictions);
    }
    
    return ruleBasedResult;
  }
}
```

## Option 4: Lightweight On-Device Model

### Using Mobile-BERT or DistilBERT
```dart
// Smaller transformer models optimized for mobile
// Can be fine-tuned for SMS classification
// Size: ~100MB vs 500MB+ for full BERT
```

## Training Data Structure for SMS Classification

```json
{
  "training_data": [
    {
      "text": "Sent Rs.30.00 From HDFC Bank A/C *7717...",
      "labels": {
        "is_transaction": true,
        "transaction_type": "debit",
        "payment_method": "upi",
        "bank": "hdfc",
        "amount": 30.00
      }
    }
  ]
}
```

## Recommended Architecture

1. **Data Collection Phase**
   - Collect anonymized SMS samples
   - Label with transaction details
   - Create training dataset

2. **Model Training** (Python/Colab)
   ```python
   import tensorflow as tf
   from tensorflow.keras import layers
   
   model = tf.keras.Sequential([
       layers.Embedding(vocab_size, 128),
       layers.LSTM(64),
       layers.Dense(32, activation='relu'),
       layers.Dense(4, activation='softmax')
   ])
   ```

3. **Model Optimization**
   ```python
   # Convert to TFLite
   converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
   converter.optimizations = [tf.lite.Optimize.DEFAULT]
   tflite_model = converter.convert()
   ```

4. **Flutter Integration**
   - Add model to assets
   - Load and run inference
   - Cache predictions

## Benefits of ML Approach

1. **Better Generalization**: Handle new bank formats automatically
2. **Multi-bank Support**: Train on multiple bank patterns
3. **Confidence Scores**: Know when parsing might be incorrect
4. **Continuous Learning**: Update model without changing code
5. **Language Support**: Handle regional languages

## Next Steps

1. Start with TFLite for maximum flexibility
2. Collect training data from actual SMS
3. Train a simple LSTM/CNN model
4. Test accuracy vs rule-based approach
5. Deploy as A/B test

## Performance Considerations

- Model size: Keep under 10MB
- Inference time: <100ms per SMS
- Memory usage: Load model once, reuse
- Battery impact: Minimal for text classification