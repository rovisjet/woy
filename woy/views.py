# views.py
from rest_framework import viewsets
from .models import Ring, RingEra, RingImage
from .serializers import RingSerializer, RingEraSerializer, RingImageSerializer

class RingViewSet(viewsets.ModelViewSet):
    queryset = Ring.objects.all().order_by('index')
    serializer_class = RingSerializer

class RingEraViewSet(viewsets.ModelViewSet):
    queryset = RingEra.objects.all().order_by('start_day')
    serializer_class = RingEraSerializer

class RingImageViewSet(viewsets.ModelViewSet):
    queryset = RingImage.objects.all().order_by('order')
    serializer_class = RingImageSerializer
