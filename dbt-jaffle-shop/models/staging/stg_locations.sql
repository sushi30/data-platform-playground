with

source as (

    select * from {{ source('ecom', 'raw_stores') }}

),

longlat as (

    select * from {{ source('ecom', 'raw_longlat') }}

),

renamed as (

    select

        ----------  ids
        s.id as location_id,

        ---------- text
        s.name as location_name,

        ---------- numerics
        s.tax_rate,
        ll.latitude,
        ll.longitude,

        ---------- timestamps
        {{ dbt.date_trunc('day', 's.opened_at') }} as opened_date

    from source s
    left join longlat ll on s.name = ll.city

)

select * from renamed
