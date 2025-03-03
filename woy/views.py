# views.py
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.contrib.auth.models import User
from django.db import transaction
from .models import Ring, RingEra, RingImage, UserRingPreference
from .serializers import (
    RingSerializer, 
    RingEraSerializer, 
    RingImageSerializer,
    UserRingPreferenceSerializer,
    UserRingUpdateSerializer
)

# Add a simple user serializer
from rest_framework import serializers

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class UserViewSet(viewsets.ViewSet):
    """Viewset for user-related actions"""
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        """Get the current user's information"""
        # For demo purposes, use the first user
        # In a real app, you'd use request.user
        user = User.objects.first()
        serializer = UserSerializer(user)
        return Response(serializer.data)

class RingViewSet(viewsets.ModelViewSet):
    queryset = Ring.objects.all().order_by('index')
    serializer_class = RingSerializer
    
    @action(detail=False, methods=['get'])
    def public(self, request):
        public_rings = Ring.objects.filter(is_public=True).order_by('index')
        serializer = self.get_serializer(public_rings, many=True)
        return Response(serializer.data)

class RingEraViewSet(viewsets.ModelViewSet):
    queryset = RingEra.objects.all().order_by('start_day')
    serializer_class = RingEraSerializer

class RingImageViewSet(viewsets.ModelViewSet):
    queryset = RingImage.objects.all().order_by('order')
    serializer_class = RingImageSerializer

class UserRingViewSet(viewsets.ViewSet):
    """
    Viewset for managing user ring preferences
    """
    
    def list(self, request):
        """Get all rings for the current user"""
        # For demo purposes, use the first user
        # In a real app, you'd use request.user
        user = User.objects.first()
        
        # Get the user's ring preferences
        preferences = UserRingPreference.objects.filter(user=user).order_by('display_order')
        
        # Get the associated rings
        ring_ids = preferences.values_list('ring_id', flat=True)
        rings = Ring.objects.filter(id__in=ring_ids).order_by('index')
        
        serializer = RingSerializer(rings, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'], url_path='update')
    def update_rings(self, request):
        """Update the user's ring preferences"""
        # For demo purposes, use the first user
        # In a real app, you'd use request.user
        user = User.objects.first()
        
        # Validate request data
        serializer = UserRingUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        ring_ids = serializer.validated_data['ring_ids']
        
        # Get the rings
        rings = Ring.objects.filter(id__in=ring_ids)
        
        # Check if all ring IDs are valid
        if len(rings) != len(ring_ids):
            return Response(
                {'error': 'One or more ring IDs are invalid'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        with transaction.atomic():
            # Delete all existing preferences
            UserRingPreference.objects.filter(user=user).delete()
            
            # Create new preferences
            for i, ring_id in enumerate(ring_ids):
                UserRingPreference.objects.create(
                    user=user,
                    ring_id=ring_id,
                    display_order=i
                )
        
        return Response({'status': 'Ring preferences updated successfully'})
