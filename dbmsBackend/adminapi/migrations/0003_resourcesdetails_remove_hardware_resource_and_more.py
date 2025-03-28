# Generated by Django 5.1.3 on 2024-12-02 21:06

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("adminapi", "0002_userroombooking_user_role"),
    ]

    operations = [
        migrations.CreateModel(
            name="ResourcesDetails",
            fields=[
                (
                    "resource",
                    models.OneToOneField(
                        on_delete=django.db.models.deletion.CASCADE,
                        primary_key=True,
                        related_name="details",
                        serialize=False,
                        to="adminapi.resources",
                    ),
                ),
                ("brand", models.CharField(blank=True, max_length=255, null=True)),
                (
                    "device_type",
                    models.CharField(blank=True, max_length=255, null=True),
                ),
                (
                    "model_number",
                    models.CharField(blank=True, max_length=50, null=True),
                ),
                (
                    "device_condition",
                    models.CharField(blank=True, max_length=50, null=True),
                ),
                ("warranty_status", models.BooleanField(blank=True, null=True)),
                ("date_purchased", models.DateField(blank=True, null=True)),
                ("author", models.CharField(blank=True, max_length=255, null=True)),
                ("publisher", models.CharField(blank=True, max_length=255, null=True)),
                ("publication_year", models.IntegerField(blank=True, null=True)),
                ("edition", models.IntegerField(blank=True, null=True)),
                ("genre", models.CharField(blank=True, max_length=100, null=True)),
                ("language", models.CharField(blank=True, max_length=50, null=True)),
                ("hardware_flag", models.BooleanField(default=False)),
                ("books_flag", models.BooleanField(default=False)),
            ],
            options={
                "db_table": "resources_details",
            },
        ),
        migrations.RemoveField(
            model_name="hardware",
            name="resource",
        ),
        migrations.AlterModelTable(
            name="resources",
            table="resources",
        ),
        migrations.CreateModel(
            name="Rents",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("reservation_date", models.DateField()),
                ("return_date", models.DateField()),
                (
                    "payment",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="rents",
                        to="adminapi.payment",
                    ),
                ),
                (
                    "resource",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="rents",
                        to="adminapi.resources",
                    ),
                ),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="rents",
                        to="adminapi.userroombooking",
                    ),
                ),
            ],
            options={
                "db_table": "rents",
                "unique_together": {("resource", "payment", "user")},
            },
        ),
        migrations.RenameModel(
            old_name="Resource",
            new_name="Resources",
        ),
        migrations.CreateModel(
            name="RoomPolicy",
            fields=[
                ("policy_id", models.AutoField(primary_key=True, serialize=False)),
                ("policy_text", models.TextField()),
                (
                    "room",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="policies",
                        to="adminapi.room",
                    ),
                ),
                (
                    "user",
                    models.ForeignKey(
                        null=True,
                        on_delete=django.db.models.deletion.SET_NULL,
                        related_name="policies",
                        to="adminapi.userroombooking",
                    ),
                ),
            ],
            options={
                "db_table": "room_policy",
            },
        ),
        migrations.DeleteModel(
            name="Book",
        ),
        migrations.DeleteModel(
            name="Hardware",
        ),
    ]
