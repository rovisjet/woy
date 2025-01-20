# serializers.py
from rest_framework import serializers
from .models import Circle, Era, Event

class EraSerializer(serializers.ModelSerializer):
    class Meta:
        model = Era
        fields = ['id', 'circle', 'name', 'description', 'start_day', 'end_day', 'color']

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = ['id', 'circle_id', 'era', 'name', 'image', 'description', 'degree', 'day']

class CircleSerializer(serializers.ModelSerializer):
    all_eras = EraSerializer(many=True, read_only=True, source='eras')
    all_events = EventSerializer(many=True, read_only=True, source='events')

    class Meta:
        model = Circle
        fields = ['id', 'name', 'description', 'days_in_cycle', 'repeats', 'color', 'all_eras', 'all_events']
