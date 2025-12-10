import json
from kafka import KafkaConsumer
from collections import defaultdict

class RealTimeAnalytics:
    def __init__(self):
        self.department_stats = defaultdict(lambda: {'count': 0, 'total_marks': 0})
        self.grade_distribution = defaultdict(int)
        self.total_records = 0
    
    def update_stats(self, data):
        self.total_records += 1
        
        dept = data['department']
        marks = data['marks']
        grade = data['grade']
        
        self.department_stats[dept]['count'] += 1
        self.department_stats[dept]['total_marks'] += marks
        self.grade_distribution[grade] += 1
        
        if self.total_records % 5 == 0:
            self.print_analytics()
    
    def print_analytics(self):
        print("\n" + "="*50)
        print("REAL-TIME ANALYTICS DASHBOARD")
        print("="*50)
        print(f"Total Records Processed: {self.total_records}")
        print("\nDepartment-wise Performance:")
        for dept, stats in self.department_stats.items():
            avg = stats['total_marks'] / stats['count'] if stats['count'] > 0 else 0
            print(f"  {dept}: {stats['count']} students | Avg Marks: {avg:.1f}")
        
        print("\nGrade Distribution:")
        for grade, count in self.grade_distribution.items():
            print(f"  {grade}: {count} students")
        print("="*50)

def main():
    analytics = RealTimeAnalytics()
    
    consumer = KafkaConsumer(
        'cloud-stream',
        bootstrap_servers='localhost:9094',
        auto_offset_reset='earliest',
        enable_auto_commit=True,
        group_id='cloud-migration-group',
        value_deserializer=lambda m: json.loads(m.decode('utf-8'))
    )
    
    print("="*60)
    print("CLOUD MIGRATION STREAMING PIPELINE - CONSUMER")
    print("="*60)
    print("Listening for real-time data from Kafka topic 'cloud-stream'...")
    print("Press Ctrl+C to stop\n")
    
    try:
        for message in consumer:
            data = message.value
            print(f"\n[Topic: {message.topic}] [Partition: {message.partition}]")
            print(f"Received: {json.dumps(data, indent=2)}")
            analytics.update_stats(data)
            
    except KeyboardInterrupt:
        print("\n\nConsumer stopped.")
        print("Final Analytics Summary:")
        analytics.print_analytics()

if __name__ == "__main__":
    main()