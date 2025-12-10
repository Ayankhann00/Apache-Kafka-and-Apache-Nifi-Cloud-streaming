import csv
import json
import time
from kafka import KafkaProducer
from datetime import datetime

class DataTransformer:
    @staticmethod
    def transform_student_record(row):
        transformed = {
            'student_id': int(row['id']),
            'student_name': row['name'].title(),
            'department': row['department'].upper(),
            'marks': int(row['marks']),
            'grade': DataTransformer.calculate_grade(int(row['marks'])),
            'timestamp': datetime.now().isoformat(),
            'batch_id': 'batch_001',
            'cloud_ready': True
        }
        return transformed
    
    @staticmethod
    def calculate_grade(marks):
        if marks >= 90:
            return 'A'
        elif marks >= 80:
            return 'B'
        elif marks >= 70:
            return 'C'
        else:
            return 'D'

def main():
    producer = KafkaProducer(
        bootstrap_servers='localhost:9094',
        value_serializer=lambda v: json.dumps(v).encode('utf-8'),
        acks='all',
        retries=3
    )
    
    print("Starting batch to stream migration pipeline...")
    print("Reading from legacy CSV file...")
    
    try:
        with open('sample_data/students.csv', 'r') as file:
            reader = csv.DictReader(file)
            record_count = 0
            
            for row in reader:
                transformed_data = DataTransformer.transform_student_record(row)
                
                producer.send('cloud-stream', transformed_data)
                producer.send('student-analytics', transformed_data)
                
                print(f"[{datetime.now().strftime('%H:%M:%S')}] Migrated: {transformed_data}")
                record_count += 1
                
                time.sleep(0.5)
        
        producer.flush()
        print(f"\nMigration complete! {record_count} records processed.")
        print("Data now available in real-time via Kafka topics.")
        
    except FileNotFoundError:
        print("Error: students.csv file not found!")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()