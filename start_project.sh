echo "🚀 CLOUD MIGRATION PROJECT STARTING..."
echo "======================================"

echo "1. Starting Docker services..."
docker-compose up -d

echo "Waiting 45 seconds for all services to start (Kafka takes time)..."
sleep 45

echo "2. Creating Kafka topics..."
echo "   Creating 'cloud-stream' topic..."
docker-compose exec kafka kafka-topics --create \
  --topic cloud-stream \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1 2>/dev/null || echo "   Topic already exists"

echo "   Creating 'student-analytics' topic..."
docker-compose exec kafka kafka-topics --create \
  --topic student-analytics \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1 2>/dev/null || echo "   Topic already exists"

echo ""
echo "✅ ALL SERVICES ARE RUNNING!"
echo ""
echo "📊 ACCESS POINTS:"
echo "   • NiFi UI:    http://localhost:8080/nifi"
echo "   • Kafka:      localhost:9092"
echo "   • Zookeeper:  localhost:2181"
echo ""
echo "📝 NEXT STEPS (open separate terminals):"
echo "   Terminal 2: Install dependencies: pip3 install kafka-python"
echo "   Terminal 2: Run Producer: python3 kafka_producer/producer.py"
echo "   Terminal 3: Run Consumer: python3 kafka_consumer/consumer.py"
echo ""
echo "🔍 MONITORING:"
echo "   Check logs: docker-compose logs -f"
echo "   Check containers: docker-compose ps"
echo ""
echo "🛑 TO STOP: docker-compose down"
echo "======================================"

