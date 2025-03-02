# views.py
from rest_framework import viewsets
from .models import Circle, Era, Event, Ring, RingEra, RingImage
from .serializers import CircleSerializer, EraSerializer, EventSerializer, RingSerializer, RingEraSerializer, RingImageSerializer

class CircleViewSet(viewsets.ReadOnlyModelViewSet):  # Read-only for now
    queryset = Circle.objects.all().order_by('days_in_cycle')
    serializer_class = CircleSerializer

class EraViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Era.objects.all().order_by('start_day')
    serializer_class = EraSerializer

class EventViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Event.objects.all().order_by('day')
    serializer_class = EventSerializer

class RingViewSet(viewsets.ModelViewSet):
    queryset = Ring.objects.all().order_by('index')
    serializer_class = RingSerializer

class RingEraViewSet(viewsets.ModelViewSet):
    queryset = RingEra.objects.all().order_by('start_day')
    serializer_class = RingEraSerializer

class RingImageViewSet(viewsets.ModelViewSet):
    queryset = RingImage.objects.all().order_by('order')
    serializer_class = RingImageSerializer
