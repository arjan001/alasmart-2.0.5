@extends($active_theme)

@section('title')
    <title>{{__('user.Purchase History')}}</title>
    <meta name="description" content="{{__('user.Purchase History')}}">
@endsection

@section('frontend-content')

    <!--=============================
        PROFILE PORTFOLIO START
    ==============================-->
    <section class="wsus__profile pt_130 xs_pt_100 pb_120 xs_pb_80">

        @include('user.inc.profile_header')

        <div class="wsus__subscription_area">
            <div class="row">
                @include('user.inc.sideber')
                <div class="col-xl-9 col-lg-8">
                    <div class="wsus__profile_subdcription_overview">

                        <div class="wsus__profile_overview_table">
                            <div class="table-responsive">
                                <table class="table table-striped">
                                    <tbody>
                                        <tr>
                                            <td>Plan</td>
                                            <td>{{ $history->plan_name }}</td>
                                        </tr>
                                        <tr>
                                            <td>Expiration</td>
                                            <td>{{ $history->expiration }}</td>
                                        </tr>
                                        @php
                                            // Assuming $history->expiration_date contains the expiration date
                                            $expirationDate = \Carbon\Carbon::parse($history->expiration_date);
                                            $currentDate = \Carbon\Carbon::now();

                                            // Calculate the difference in days
                                            $daysRemaining = $currentDate->diffInDays($expirationDate);
                                        @endphp
                                        <tr>
                                            <td>Expirated Date</td>
                                            <td>{{ $history->expiration_date }}</td>
                                        </tr>
                                        <tr>
                                            <td>Remaining Day</td>
                                            <td>{{$daysRemaining}} {{__('user.Days') }}</td>
                                        </tr>
                                        <tr>
                                            <td>Number of Product</td>
                                            <td>{{$history->maximum_service}}</td>
                                        </tr>
                                        <tr>
                                            <td>Payment Method</td>
                                            <td>{{$history->payment_method}}</td>
                                        </tr>
                                        <tr>
                                            <td>Transaction</td>
                                            <td>{{$history->transaction}}</td>
                                        </tr>

                                        <tr>
                                            <td>Payment Status</td>
                                            <td>
                                                @if ($history->payment_status == 'success')
                                                    <strong>{{__('admin.Success')}}</strong>
                                                @else
                                                    <strong>{{__('admin.Pending')}}</strong>
                                                @endif
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Status</td>
                                            <td>
                                                @if ($history->status == 'active')
                                                    <strong>{{__('admin.Active')}}</strong>
                                                @else
                                                    <strong>{{__('admin.Expired')}}</strong>
                                                @endif
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        </div>
    </section>
    <!--=============================
        PROFILE PORTFOLIO END
    ==============================-->



@endsection

