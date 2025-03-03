"""woy URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import RingViewSet, RingEraViewSet, RingImageViewSet, UserRingViewSet, UserViewSet

router = DefaultRouter()
router.register(r'rings', RingViewSet)
router.register(r'ring-eras', RingEraViewSet)
router.register(r'ring-images', RingImageViewSet)
router.register(r'user/rings', UserRingViewSet, basename='user-rings')
router.register(r'user', UserViewSet, basename='user')

urlpatterns = [
    path('api/', include(router.urls)),
    path('admin/', admin.site.urls),
]

