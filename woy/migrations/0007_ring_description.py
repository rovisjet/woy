# Generated by Django 5.1.6 on 2025-03-04 00:14

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("woy", "0006_alter_ring_index"),
    ]

    operations = [
        migrations.AddField(
            model_name="ring",
            name="description",
            field=models.TextField(
                blank=True, help_text="Description of the ring", null=True
            ),
        ),
    ]
